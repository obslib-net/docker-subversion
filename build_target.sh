#/bin/bash

cd /usr/local/src

apt-get -y update; \
apt-get install -y build-essential; \
apt-get install -y unzip wget

. /usr/local/src/get_deps.sh

APR_SOURCE=apr-${APR_VERSION}
APR_UTIL_SOURCE=apr-util-${APR_UTIL_VERSION}
SUBVERSION_SOURCE=subversion-${SUBVERSION_VERSION}
EXPAT_SOURCE=expat-${EXPAT_VERSION};EXPAT_PREFIX=R_$(echo $EXPAT_VERSION | sed -e 's/\./_/g')
ZLIB_SOURCE=zlib-${ZLIB_VERSION}
SQLITE_SOURCE=sqlite-amalgamation-$(echo $(printf %d%02d%02d%02d $(echo $SQLITE_VERSION | sed -e 's/\./ /g')))

wget https://dist.apache.org/repos/dist/release/apr/${APR_SOURCE}.tar.gz
wget https://dist.apache.org/repos/dist/release/apr/${APR_UTIL_SOURCE}.tar.gz
wget https://dist.apache.org/repos/dist/release/subversion/${SUBVERSION_SOURCE}.tar.gz
wget https://github.com/libexpat/libexpat/releases/download/${EXPAT_PREFIX}/${EXPAT_SOURCE}.tar.gz
wget https://www.sqlite.org/${SQLITE_VERSION_REL_YEAR}/${SQLITE_SOURCE}.zip
wget https://www.zlib.net/${ZLIB_SOURCE}.tar.gz

tar zxvf ${APR_SOURCE}.tar.gz
cd ${APR_SOURCE}
./configure --prefix=/usr/local/subversion
make
make install
cd ..

tar zxvf ${ZLIB_SOURCE}.tar.gz
cd ${ZLIB_SOURCE}
./configure --prefix=/usr/local/subversion --shared --libdir=/usr/local/subversion/lib
make
make install
cd ..

tar zxvf ${EXPAT_SOURCE}.tar.gz
cd ${EXPAT_SOURCE}
./configure --prefix=/usr/local/subversion --without-xmlwf --without-examples --without-tests
make
make install
cd ..


tar zxvf ${APR_UTIL_SOURCE}.tar.gz
cd ${APR_UTIL_SOURCE}
./configure --prefix=/usr/local/subversion --with-apr=/usr/local/subversion --with-expat=/usr/local/subversion
make
make install
cd ..

unzip ${SQLITE_SOURCE}.zip

tar zxvf ${SUBVERSION_SOURCE}.tar.gz
mv ${SQLITE_SOURCE} ./${SUBVERSION_SOURCE}/sqlite-amalgamation
cd ${SUBVERSION_SOURCE}
./configure --prefix=/usr/local/subversion --with-apr=/usr/local/subversion --with-apr-util=/usr/local/subversion --with-zlib=/usr/local/subversion --with-lz4=internal --with-utf8proc=internal
make
make install
cd ..

