#!/bin/bash

set -euxo pipefail

cd /usr/local/src

# SOURCE GET
. source_get.sh

if [ -z "${SUBVERSION_VERSION}" ]; then
    exit 1
fi

## BASE
tar zxvf ${ZLIB_SOURCE}.tar.gz
cd ${ZLIB_SOURCE}
./configure --prefix=/usr/local/subversion      \
            --shared                            \
            --libdir=/usr/local/subversion/lib
make
make install
cd ..

tar zxvf ${EXPAT_SOURCE}.tar.gz
cd ${EXPAT_SOURCE}
./configure --prefix=/usr/local/subversion  \
            --without-xmlwf                 \
            --without-examples              \
            --without-tests
make
make install
cd ..

## HTTPD
tar zxvf ${APR_SOURCE}.tar.gz
cd ${APR_SOURCE}
./configure --prefix=/usr/local/subversion
make
make install
cd ..

tar zxvf ${APR_UTIL_SOURCE}.tar.gz
cd ${APR_UTIL_SOURCE}
./configure --prefix=/usr/local/subversion                      \
            --with-apr=/usr/local/subversion                    \
            --with-expat=/usr/local/subversion
make
make install
cd ..

## SUBVERSION
unzip ${SQLITE_SOURCE}.zip
tar zxvf ${SUBVERSION_SOURCE}.tar.gz
mv ${SQLITE_SOURCE} ./${SUBVERSION_SOURCE}/sqlite-amalgamation
cd ${SUBVERSION_SOURCE}
./configure --prefix=/usr/local/subversion          \
            --with-apr=/usr/local/subversion        \
            --with-apr-util=/usr/local/subversion   \
            --with-zlib=/usr/local/subversion       \
            --with-lz4=internal                     \
            --with-utf8proc=internal                \
            --with-expat=/usr/local/subversion/include:/usr/local/subversion/lib:expat  \
            --with-sasl=/usr
make
make install
cd ..

## config
rm -r -f /usr/local/subversion/share
