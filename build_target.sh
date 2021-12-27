#/bin/bash

cd /usr/local/src

apt-get -y update; \
apt-get install -y build-essential; \
apt-get install -y unzip wget

. /usr/local/src/get_deps.sh

# DEFINE
## BASE
ZLIB_SOURCE=zlib-${ZLIB_VERSION}
EXPAT_SOURCE=expat-${EXPAT_VERSION};EXPAT_PREFIX=R_$(echo $EXPAT_VERSION | sed -e 's/\./_/g')
OPENSSL_SOURCE=openssl-${OPENSSL_VERSION}

## HTTPD
APR_SOURCE=apr-${APR_VERSION}
APR_UTIL_SOURCE=apr-util-${APR_UTIL_VERSION}
PCRE_SOURCE=pcre-${PCRE_VERSION}
HTTPD_SOURCE=httpd-${HTTPD_VERSION}

## CYRUS_SASL BUILD

## SUBVERSION BUILD


## SUBVERSION
SQLITE_SOURCE=sqlite-amalgamation-$(echo $(printf %d%02d%02d%02d $(echo $SQLITE_VERSION | sed -e 's/\./ /g')))
SUBVERSION_SOURCE=subversion-${SUBVERSION_VERSION}

# GET
## BASE
wget https://www.zlib.net/${ZLIB_SOURCE}.tar.gz
wget https://github.com/libexpat/libexpat/releases/download/${EXPAT_PREFIX}/${EXPAT_SOURCE}.tar.gz
wget https://www.openssl.org/source/${OPENSSL_SOURCE}.tar.gz


## HTTPD
wget https://dist.apache.org/repos/dist/release/apr/${APR_SOURCE}.tar.gz
wget https://dist.apache.org/repos/dist/release/apr/${APR_UTIL_SOURCE}.tar.gz
wget https://ftp.pcre.org/pub/pcre/${PCRE_SOURCE}.tar.gz
wget https://dist.apache.org/repos/dist/release/httpd/${HTTPD_SOURCE}.tar.gz

## SUBVERSION LIB
wget https://www.sqlite.org/${SQLITE_VERSION_REL_YEAR}/${SQLITE_SOURCE}.zip

## SUBVERSION
wget https://dist.apache.org/repos/dist/release/subversion/${SUBVERSION_SOURCE}.tar.gz

# install extend lib
apt-get install -y libsasl2-dev libldap2-dev

# BUILD
## INIT
echo "/usr/local/subversion/lib" >  /etc/ld.so.conf.d/subversion.conf
echo "/usr/local/httpd/lib"      >> /etc/ld.so.conf.d/subversion.conf
ldconfig

export LD_LIBRARY_PATH=/usr/local/subversion/lib:/usr/local/httpd/lib:$LD_LIBRARY_PATH
export LD_RUN_PATH=/usr/local/subversion/lib:/usr/local/httpd/lib:$LD_RUN_PATH

## BASE
tar zxvf ${ZLIB_SOURCE}.tar.gz
cd ${ZLIB_SOURCE}
./configure --prefix=/usr/local/subversion      \
            --shared                            \
            --libdir=/usr/local/subversion/lib
make
make install
cd ..

tar zxvf ${OPENSSL_SOURCE}.tar.gz
cd ${OPENSSL_SOURCE}
./config    --prefix=/usr/local/httpd                          \
            --with-zlib-include=/usr/local/httpd/include       \
            --with-zlib-lib=/usr/local/httpd/lib               \
            shared zlib-dynamic
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
./configure --prefix=/usr/local/httpd
make
make install
cd ..

tar zxvf ${APR_UTIL_SOURCE}.tar.gz
cd ${APR_UTIL_SOURCE}
./configure --prefix=/usr/local/httpd                           \
            --with-expat=/usr/local/subversion                  \
            --with-crypto                                       \
            --with-openssl=/usr/local/httpd                     \
            --with-ldap                                         \
            --with-apr=/usr/local/httpd
make
make install
cd ..

tar zxvf ${PCRE_SOURCE}.tar.gz
cd ${PCRE_SOURCE}
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
            --enable-so                                         \
            --enable-module=so                                  \
            --with-pcre=/usr/local/httpd/bin/pcre-config        \
            --enable-mods-shared="all ssl ldap cache proxy authn_alias mem_cache file_cache authnz_ldap charset_lite dav_lock disk_cache"
make
make install
cd ..

## SUBVERSION
# build
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
            --with-expat=/usr/local/subversion/include:/usr/local/subversion/lib:expat  \
            --with-sasl=/usr
make
make install
cd ..


## config
rm -r -f /usr/local/httpd/share
rm -r -f /usr/local/subversion/share
