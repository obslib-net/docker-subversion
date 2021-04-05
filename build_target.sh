#/bin/bash

cd /usr/local/src

apt-get -y update; \
apt-get install -y build-essential; \
apt-get install -y unzip wget

. /usr/local/src/get_deps.sh

### DEFINE
## BASE
ZLIB_SOURCE=zlib-${ZLIB_VERSION}

## CYRUS_SASL BUILD
CYRUS_SASL_SOURCE=cyrus-sasl-${CYRUS_SASL_VERSION}

## SUBVERSION BUILD
APR_SOURCE=apr-${APR_VERSION}
APR_UTIL_SOURCE=apr-util-${APR_UTIL_VERSION}
EXPAT_SOURCE=expat-${EXPAT_VERSION};EXPAT_PREFIX=R_$(echo $EXPAT_VERSION | sed -e 's/\./_/g')
SQLITE_SOURCE=sqlite-amalgamation-$(echo $(printf %d%02d%02d%02d $(echo $SQLITE_VERSION | sed -e 's/\./ /g')))

## SUBVERSION
SUBVERSION_SOURCE=subversion-${SUBVERSION_VERSION}

### GET
## BASE
wget https://www.zlib.net/${ZLIB_SOURCE}.tar.gz

## CYRUS_SASL
wget https://github.com/cyrusimap/cyrus-sasl/releases/download/${CYRUS_SASL_SOURCE}/${CYRUS_SASL_SOURCE}.tar.gz

## SUBVERSION LIB
wget https://dist.apache.org/repos/dist/release/apr/${APR_SOURCE}.tar.gz
wget https://dist.apache.org/repos/dist/release/apr/${APR_UTIL_SOURCE}.tar.gz
wget https://github.com/libexpat/libexpat/releases/download/${EXPAT_PREFIX}/${EXPAT_SOURCE}.tar.gz
wget https://www.sqlite.org/${SQLITE_VERSION_REL_YEAR}/${SQLITE_SOURCE}.zip

## SUBVERSION
wget https://dist.apache.org/repos/dist/release/subversion/${SUBVERSION_SOURCE}.tar.gz

### BUILD
## BASE
tar zxvf ${ZLIB_SOURCE}.tar.gz
cd ${ZLIB_SOURCE}
./configure --prefix=/usr/local/subversion      \
            --shared                            \
            --libdir=/usr/local/subversion/lib
make
make install
cd ..


## CYRUS_SASL
tar zxvf ${CYRUS_SASL_SOURCE}.tar.gz
cd ${CYRUS_SASL_SOURCE}
./configure --prefix=/usr/local/subversion           \
            --enable-checkapop=no                    \
            --enable-cram=no                         \
            --enable-digest=no                       \
            --enable-scram=no                        \
            --enable-otp=no                          \
            --enable-plain=no                        \
            --enable-anon=no                         \
            --with-saslauthd=no
make
make install
cd ..


## SUBVERSION LIB
tar zxvf ${APR_SOURCE}.tar.gz
cd ${APR_SOURCE}
./configure --prefix=/usr/local/subversion
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
            --with-sasl=/usr/local/subversion
make
make install
cd ..

