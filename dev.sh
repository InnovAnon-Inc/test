#! /usr/bin/env bash
set -euxo nounset
(( $# ))

export PATH=/usr/lib/ccache:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export DISTCC_VERBOSE=1
export DISTCC_FALLBACK=0

git reset --hard
git clean -fdX
git clean -fdX

autoreconf -i
./configure
make
make check
make distcheck

#git clean -dfX
[[ ! -e .gitignore-tmp ]]
sort -u .gitignore > .gitignore-tmp
mv -v .gitignore{-tmp,}

git pull
git add .
git commit -m "$*"
git push
git clean -dfX

