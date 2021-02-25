#/bin/bash

apt-get -y update;                   \
apt-get -y upgrade;                  \
apt-get install -y build-essential;  \
apt-get install -y unzip wget

cd /usr/local/src

wget https://dist.apache.org/repos/dist/release/apr/apr-1.7.0.tar.gz
wget https://dist.apache.org/repos/dist/release/apr/apr-util-1.6.1.tar.gz
wget https://dist.apache.org/repos/dist/release/subversion/subversion-1.14.1.tar.gz
wget https://github.com/libexpat/libexpat/releases/download/R_2_2_10/expat-2.2.10.tar.gz
wget https://www.sqlite.org/2021/sqlite-amalgamation-3340100.zip
wget https://www.zlib.net/zlib-1.2.11.tar.gz

tar zxvf apr-1.7.0.tar.gz
cd apr-1.7.0
./configure --prefix=/usr/local/subversion
make
make install
cd ..

tar zxvf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure --prefix=/usr/local/subversion --shared --libdir=/usr/local/subversion/lib
make
make install
cd ..

tar zxvf expat-2.2.10.tar.gz
cd expat-2.2.10
./configure --prefix=/usr/local/subversion --without-xmlwf --without-examples --without-tests
make
make install
cd ..


tar zxvf apr-util-1.6.1.tar.gz
cd apr-util-1.6.1
./configure --prefix=/usr/local/subversion --with-apr=/usr/local/subversion --with-expat=/usr/local/subversion
make
make install
cd ..

unzip sqlite-amalgamation-3340100.zip

tar zxvf subversion-1.14.1.tar.gz
mv sqlite-amalgamation-3340100 ./subversion-1.14.1/sqlite-amalgamation
cd subversion-1.14.1
./configure --prefix=/usr/local/subversion --with-apr=/usr/local/subversion --with-apr-util=/usr/local/subversion --with-zlib=/usr/local/subversion --with-lz4=internal --with-utf8proc=internal
make
make install
cd ..

cd /usr/local/
tar zcvf subversion.tar.gz ./subversion/
