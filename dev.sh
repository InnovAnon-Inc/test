#! /usr/bin/env bash
set -euxo nounset
(( $# ))

cmake -S . -B build -GNinja -DCMAKE_BUILD_TYPE=Debug
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

