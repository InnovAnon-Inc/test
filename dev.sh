#! /usr/bin/env bash
set -euxo nounset
(( $# ))

cmake -S . -B build                 \
  -DKERNELHEADERS_DIR=$HOME/usr/src \
  -GNinja -DCMAKE_BUILD_TYPE=Debug
cmake --build build                 \
  -DKERNELHEADERS_DIR=$HOME/usr/src
cmake --build build                 \
  -DKERNELHEADERS_DIR=$HOME/usr/src \
  --target test
cmake --build build                 \
  -DKERNELHEADERS_DIR=$HOME/usr/src \
  --target docs
#cpack --build build --config CPackConfig.cmake
#cpack --build build --config CPackSourceConfig.cmake
cmake --build build                 \
  -DKERNELHEADERS_DIR=$HOME/usr/src \
  --target package
cmake --build build                 \
  -DKERNELHEADERS_DIR=$HOME/usr/src \
  --target package_source

#git clean -dfX
[[ ! -e .gitignore-tmp ]]
sort -u .gitignore > .gitignore-tmp
mv -v .gitignore{-tmp,}

git pull
git add .
git commit -m "$*"
git push
git clean -dfX

