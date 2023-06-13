#! /usr/bin/env bash
set -euxo nounset

./autogen.sh
./configure
make dist
make clean-local

#find

t=$(mktemp -d) || exit
trap "rm -fr -- '$t'" EXIT

tar --extract --file test-1.0.0.tar.gz
cd test-1.0.0
./configure 
make 
DESTDIR=$t make install
cd ..
rm -r test-1.0.0
rm test-1.0.0.tar.gz

#find

rm -fr -- "$t"
trap - EXIT
exit

