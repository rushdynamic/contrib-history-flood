#!/bin/bash

get_dir_and_date() {
    repo_name=$(echo $1 | awk -F'/' '{ print $NF }' | sed 's/\.git$//')
    formatted_date=$(date -j -f "%d-%m-%Y" "$2" +"%a %b %d 00:00 %Y %z")
    echo ">> Git repo dir: $repo_name"
    echo ">> Formatted date: $formatted_date"
}

clone_repo_if_not_exists() {
    if [ -d $repo_name ]; then
        echo ">> Git repo dir already exists"
        true
    else
        echo ">> Cloning repo"
        git clone $1
    fi
    cd $repo_name && echo ">> Inside Git dir"
}

commit_and_push_dummy() {
    rm README.md
    touch README.md
    git add . > /dev/null && echo ">> Added files"
    git commit -m "test commit" > /dev/null && echo ">> Created commit"
    git push origin main > /dev/null && echo ">> Pushing original commit"
}

update_date() {
    git commit --amend --date="$formatted_date" --no-edit > /dev/null && echo ">> Updated author date"
    GIT_COMMITTER_DATE="$formatted_date" git commit --amend --no-edit > /dev/null && echo ">> Updated committer date"
    git push origin main -f > /dev/null && echo ">> Pushed final changes"
}

get_dir_and_date $1 $2
clone_repo_if_not_exists $1
commit_and_push_dummy
update_date