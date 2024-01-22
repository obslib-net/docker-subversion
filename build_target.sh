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
LIBRESSL_SOURCE=libressl-${LIBRESSL_VERSION}

## HTTPD
APR_SOURCE=apr-${APR_VERSION}
APR_UTIL_SOURCE=apr-util-${APR_UTIL_VERSION}
PCRE2_SOURCE=pcre2-${PCRE2_VERSION}
HTTPD_SOURCE=httpd-${HTTPD_VERSION}

## SUBVERSION
SQLITE_SOURCE=sqlite-amalgamation-$(echo $(printf %d%02d%02d%02d $(echo $SQLITE_VERSION | sed -e 's/\./ /g')))
SUBVERSION_SOURCE=subversion-${SUBVERSION_VERSION}

# GET
## BASE
wget https://www.zlib.net/${ZLIB_SOURCE}.tar.gz
wget https://github.com/libexpat/libexpat/releases/download/${EXPAT_PREFIX}/${EXPAT_SOURCE}.tar.gz
wget https://cdn.openbsd.org/pub/OpenBSD/LibreSSL/${LIBRESSL_SOURCE}.tar.gz

## HTTPD
wget https://dist.apache.org/repos/dist/release/apr/${APR_SOURCE}.tar.gz
wget https://dist.apache.org/repos/dist/release/apr/${APR_UTIL_SOURCE}.tar.gz
wget https://github.com/PCRE2Project/pcre2/releases/download/${PCRE2_SOURCE}/${PCRE2_SOURCE}.tar.gz

wget https://dist.apache.org/repos/dist/release/httpd/${HTTPD_SOURCE}.tar.gz


## SUBVERSION
wget https://www.sqlite.org/${SQLITE_VERSION_REL_YEAR}/${SQLITE_SOURCE}.zip
wget https://archive.apache.org/dist/subversion/${SUBVERSION_SOURCE}.tar.gz

# INSTALL EXTEND LIB
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
./configure --prefix=/usr/local/httpd           \
            --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz=/usr/local/httpd \
            --disable-static
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
