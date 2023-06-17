#! /usr/bin/env bash
set -euxo nounset
(( $# ))

#autoreconf -i
#./configure
#make
#make check
#make distcheck

cmake -S . -B build -GNinja
cmake --build build
cmake --build build --target test
cmake --build build --target docs

#git clean -dfX
[[ ! -e .gitignore-tmp ]]
sort -u .gitignore > .gitignore-tmp
mv -v .gitignore{-tmp,}

git add .
git commit -m "$*"
git push
git clean -dfX

