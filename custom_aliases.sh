# Alias to delete all the unused local branches
alias gcln='git fetch -p && git branch -vv | grep ": gone]" | awk "{print \$1}" | xargs -r git branch -d'
