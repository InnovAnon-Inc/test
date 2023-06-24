#! /usr/bin/env bash
set -euxo nounset
(( $# ))

cmake -S . -B build                  \
  -DKERNEL_HEADERS_DIR=$HOME/usr/src \
  -DKERNEL_MODULES_DIR=$HOME/usr/lib/modules/6.2.10-1-aarch64-ARCH/build \
  -GNinja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
cmake --build build --target test
cmake --build build --target docs
#cpack --build build --config CPackConfig.cmake
#cpack --build build --config CPackSourceConfig.cmake
cmake --build build --target package
cmake --build build --target package_source

#git clean -dfX
[[ ! -e .gitignore-tmp ]]
sort -u .gitignore > .gitignore-tmp
mv -v .gitignore{-tmp,}

git pull
git add .
git commit -m "$*"
git push
git clean -dfX

