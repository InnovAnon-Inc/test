#! /usr/bin/env bash
set -euxo nounset
[[ $# > 1 ]]

autoreconf -i
./configure
make
make check
make distcheck

#git clean -dfX
[[ ! -e .gitignore-tmp ]]
sort -u .gitignore > .gitignore-tmp
mv -v .gitignore{-tmp,}

git add .
git commit -m "$*"
git push
git clean -dfX

