 #!/bin/bash

cd /Users/gokul/rushd/dummy-flood-repo
rm README.md
touch README.md
git add . && echo ">> Added files"
git commit -m "test commit" && echo ">> Created commit"
git push origin main && echo ">> Pushing original commit"
git commit --amend --date="Fri Feb 16 14:00 2024 +0100" --no-edit && echo ">> Updated author date"
GIT_COMMITTER_DATE="Fri Feb 16 14:00 2024 +0100" git commit --amend --no-edit && echo ">> Updated committer date"
git push origin main -f && echo ">> Pushed final changes"