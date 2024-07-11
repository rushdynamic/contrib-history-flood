#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

repo_url=$1
start_date=$2
end_date=$3
formatted_dates=()

get_formatted_dates() {
    if [ -z "$2" ]; then
        formatted_dates=("$(date -j -f "%d-%m-%Y" "$1" +"%a %b %d 00:00 %Y %z")")
    else
        start_sec=$(date -j -f "%d-%m-%Y" "$1" +"%s")
        end_sec=$(date -j -f "%d-%m-%Y" "$2" +"%s")
        curr=$start_sec
        while [ $curr -le $end_sec ]; do
            formatted_dates+=("$(date -j -f "%s" "$curr" +"%a %b %d %H:%M %Y %z")")
            curr=$((curr + 86400))
        done
    fi
    echo -e ">>${YELLOW} Finished formatting dates ${NC}"
}

get_git_repo_dir() {
    repo_name=$(echo $1 | awk -F'/' '{ print $NF }' | sed 's/\.git$//')
    echo -e ">>${YELLOW} Parsed Git repo directory: ${BLUE}$repo_name${NC}"
}

clone_repo_if_not_exists() {
    if [ -d $repo_name ]; then
        echo -e ">>${YELLOW} Git repo dir already exists, proceeding${NC}"
        true
    else
        echo -e ">>${YELLOW} Cloning repo...${NC}"
        git clone $1
    fi
    cd $repo_name
}

create_dummy_commit() {
    rm "$date" > /dev/null 2>&1
    touch "$date.md"
    git add . > /dev/null && echo
    git commit -m "test commit" > /dev/null
}

update_date() {
    git commit --amend --date="$1" --no-edit > /dev/null
    GIT_COMMITTER_DATE="$1" git commit --amend --no-edit > /dev/null
}

push_changes() {
    git push origin main -f > /dev/null
    echo -e ">>${GREEN} SUCCESS!${NC}"
}

get_formatted_dates $start_date $end_date
get_git_repo_dir $repo_url $start_date
clone_repo_if_not_exists $repo_url
for date in "${formatted_dates[@]}"; do
    create_dummy_commit "$date" # make this fuzzy -- multiple commits per date
    update_date "$date"
done
echo -e ">>${YELLOW} Created dummy commits for ${BLUE}${#formatted_dates[@]} ${YELLOW}dates${NC}"
push_changes
#TODO:
# improve logs formatting -- add colors