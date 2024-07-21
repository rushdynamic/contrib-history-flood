#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

repo_url=
start_date=
end_date=
fuzzy=false
formatted_dates=()

usage() {
    cat << "EOF"
Usage: ./contrib_flood.sh -r <repo_url> -s <start_date> [-e <end_date>] [--fuzzy]

Options:
  -r <repo_url>     Repository URL (required).
  -s <start_date>   Start date in the format `dd-mm-yyyy` (required).
  -e <end_date>     End date in the format `dd-mm-yyyy` for using a date-range (optional).
  --fuzzy           Enable fuzzy date selection from given range (optional).
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -r)
            repo_url="$2"
            shift 2
            ;;
        -s)
            start_date="$2"
            shift 2
            ;;
        -e)
            end_date="$2"
            shift 2
            ;;
        --fuzzy)
            fuzzy=true
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            usage
            ;;
    esac
done

get_formatted_dates() {
    if [ -z "$2" ]; then
        formatted_dates=("$(date -j -f "%d-%m-%Y" "$1" +"%a %b %d 00:00 %Y %z")")
    else
        start_sec=$(date -j -f "%d-%m-%Y" "$1" +"%s")
        end_sec=$(date -j -f "%d-%m-%Y" "$2" +"%s")
        curr=$start_sec
        while [ "$curr" -le "$end_sec" ]; do
            formatted_dates+=("$(date -j -f "%s" "$curr" +"%a %b %d %H:%M %Y %z")")
            curr=$((curr + 86400))
        done
    fi
    echo -e ">>${YELLOW} Finished formatting dates ${NC}"
}

get_fuzzy_dates() {
    if [ ${#formatted_dates[@]} -gt 1 ]; then
        echo -e ">>${BLUE} Fuzzy mode enabled${NC}"
        while read -r idx; do
            indices+=("$idx")
        done <<< "$(jot -r $(jot -r 1 0 $(( ${#formatted_dates[@]} - 2 ))) 0 $(( ${#formatted_dates[@]} - 1 )))"
        for index in "${indices[@]}"; do
            unset 'formatted_dates[index]'
        done
    else
        echo -e ">>${RED} Fuzzy mode is only supported for a date range${NC}"
    fi
}

get_git_repo_dir() {
    repo_name=$(echo "$1" | awk -F'/' '{ print $NF }' | sed 's/\.git$//')
    echo -e ">>${YELLOW} Parsed Git repo directory: ${BLUE}$repo_name${NC}"
}

clone_repo_if_not_exists() {
    if [ -d "$repo_name" ]; then
        echo -e ">>${YELLOW} Git repo dir already exists, proceeding${NC}"
        true
    else
        echo -e ">>${YELLOW} Cloning repo...${NC}"
        git clone "$1"
    fi
    cd "$repo_name"
}

create_dummy_commit() {
    local counter=0
    while [[ -e "$date.md" || -e "$date$counter.md" ]]; do
        (( counter++ ))
    done
    touch "$date$counter.md"
    git add . > /dev/null
    git commit -m "test commit" > /dev/null
}

update_date() {
    git commit --amend --date="$1" --no-edit > /dev/null
    GIT_COMMITTER_DATE="$1" git commit --amend --no-edit > /dev/null
}

push_changes() {
    git push origin main -f > /dev/null
    if [ $? -eq 0 ]; then
        echo -e ">>${GREEN} SUCCESS!${NC}"
    else
        echo -e ">>${RED} FAILURE!${NC}"
    fi
}

# Exit when invalid args
if [ -z "$repo_url" ] || [ -z "$start_date" ]; then
    usage
fi
get_formatted_dates "$start_date" "$end_date"
get_git_repo_dir "$repo_url" "$start_date"
clone_repo_if_not_exists "$repo_url"
if [ "$fuzzy" = true ]; then
    get_fuzzy_dates
fi
echo -e ">>${YELLOW} Creating dummy commits for ${BLUE}${#formatted_dates[@]} ${YELLOW}dates, this might take a while...${NC}"
for date in "${formatted_dates[@]}"; do
    if [ "$fuzzy" = true ]; then
        repeat_times=$(jot -r 1 1 15)
    else
        repeat_times=1
    fi
    for (( i=0; i<$repeat_times; i++)); do
        create_dummy_commit "$date"
        update_date "$date"
    done
done
echo -e ">>${YELLOW} Pushing changes...${NC}"
push_changes