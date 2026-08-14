#!/bin/bash

set -euxo pipefail

cd /usr/local/src

## BASE
tar zxvf ${ZLIB_SOURCE}.tar.gz
cd ${ZLIB_SOURCE}
./configure --prefix=/usr/local/httpd       \
            --shared                        \
            --libdir=/usr/local/httpd/lib
make
make install
cd ..

tar zxvf ${EXPAT_SOURCE}.tar.gz
cd ${EXPAT_SOURCE}
./configure --prefix=/usr/local/httpd       \
            --without-xmlwf                 \
            --without-examples              \
            --without-tests
make
make install
cd ..

tar zxvf ${LIBRESSL_SOURCE}.tar.gz
cd ${LIBRESSL_SOURCE}
./configure --prefix=/usr/local/httpd
make
make install
cd ..

## HTTPD
tar zxvf ${APR_SOURCE}.tar.gz
cd ${APR_SOURCE}
./configure --prefix=/usr/local/httpd
make
make install
cd ..

tar zxvf ${APR_UTIL_SOURCE}.tar.gz
cd ${APR_UTIL_SOURCE}
./configure --prefix=/usr/local/httpd                           \
            --with-apr=/usr/local/httpd                         \
            --with-expat=/usr/local/httpd                       \
            --with-crypto                                       \
            --with-openssl=/usr/local/httpd                     \
            --with-ldap                                         \
            CFLAGS="-I/usr/local/httpd/include"                 \
            LDFLAGS="-L/usr/local/httpd/lib"
make
make install
cd ..

tar zxvf ${PCRE2_SOURCE}.tar.gz
cd ${PCRE2_SOURCE}
./configure --prefix=/usr/local/httpd
make
make install
cd ..

tar zxvf ${HTTPD_SOURCE}.tar.gz
cd ${HTTPD_SOURCE}
./configure --prefix=/usr/local/httpd                           \
            --with-apr=/usr/local/httpd                         \
            --with-apr-util=/usr/local/httpd                    \
            --with-ssl=/usr/local/httpd                         \
            --with-z=/usr/local/httpd                           \
            --enable-so                                         \
            --enable-module=so                                  \
            --with-pcre=/usr/local/httpd/bin/pcre2-config       \
            --enable-mods-shared="reallyall"
make
make install
cd ..

## SUBVERSION
unzip ${SQLITE_SOURCE}.zip
tar zxvf ${SUBVERSION_SOURCE}.tar.gz
mv ${SQLITE_SOURCE} ./${SUBVERSION_SOURCE}/sqlite-amalgamation
cd ${SUBVERSION_SOURCE}
./configure --prefix=/usr/local/subversion          \
            --with-apr=/usr/local/httpd             \
            --with-apr-util=/usr/local/httpd        \
            --with-zlib=/usr/local/httpd            \
            --with-lz4=internal                     \
            --with-utf8proc=internal                \
            --with-expat=/usr/local/httpd/include:/usr/local/httpd/lib:expat  \
            --with-apache-libexecdir=/usr/local/httpd/modules                 \
            --with-apxs=/usr/local/httpd/bin/apxs   \
            --with-sasl=/usr
make
make install
cd ..

## config
rm -r -f /usr/local/subversion/share
rm -r -f /usr/local/httpd/share
rm -r -f /usr/local/httpd/conf/extra
rm -r -f /usr/local/httpd/conf/original
rm -r -f /usr/local/httpd/manual
rm -r -f /usr/local/httpd/man
