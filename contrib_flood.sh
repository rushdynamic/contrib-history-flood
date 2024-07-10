 #!/bin/bash

formatted_date=$(date -j -f "%d-%m-%Y" "$1" +"%a %b %d 00:00 %Y %z")
echo ">> Formatted date: $formatted_date"
cd /Users/gokul/rushd/dummy-flood-repo
rm README.md
touch README.md
git add . && echo ">> Added files"
git commit -m "test commit" && echo ">> Created commit"
git push origin main && echo ">> Pushing original commit"
git commit --amend --date="$formatted_date" --no-edit && echo ">> Updated author date"
GIT_COMMITTER_DATE="$formatted_date" git commit --amend --no-edit && echo ">> Updated committer date"
git push origin main -f && echo ">> Pushed final changes"