#!/bin/bash

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
}

get_git_repo_dir() {
    repo_name=$(echo $1 | awk -F'/' '{ print $NF }' | sed 's/\.git$//')
    echo ">> Git repo dir: $repo_name"
}

clone_repo_if_not_exists() {
    if [ -d $repo_name ]; then
        echo ">> Git repo dir already exists, proceeding"
        true
    else
        echo ">> Cloning repo"
        git clone $1
    fi
    cd $repo_name && echo ">> Inside Git dir"
}

commit_and_push_dummy() {
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
    git push origin main -f > /dev/null && echo ">> Pushed final changes"
}

get_formatted_dates $start_date $end_date
get_git_repo_dir $repo_url $start_date
clone_repo_if_not_exists $repo_url
for date in "${formatted_dates[@]}"; do
    commit_and_push_dummy "$date" # make this fuzzy -- multiple commits per date
    update_date "$date"
done
echo ">> Created dummy files and updated dates"
push_changes
#TODO:
# improve logs formatting -- add colors