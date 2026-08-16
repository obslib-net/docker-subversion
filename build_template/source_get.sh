#!/bin/bash

set -euxo pipefail

cd /usr/local/src

# INSTALL BUILD TOOL
apt-get -y update; \
apt-get install -y build-essential; \
apt-get install -y unzip wget

# INSTALL EXTEND LIB
apt-get install -y libsasl2-dev libldap-dev

# SET VERSION
. /usr/local/src/source_version.sh
if [ -e /usr/local/src/source_version_custom.sh ]; then
    . /usr/local/src/source_version_custom.sh
fi

# SVN INIT
## SET SVN-VERSION
ZLIB_SOURCE=zlib-${ZLIB_VERSION}
EXPAT_SOURCE=expat-${EXPAT_VERSION}
EXPAT_PREFIX=R_$(echo $EXPAT_VERSION | sed -e 's/\./_/g')

APR_SOURCE=apr-${APR_VERSION}
APR_UTIL_SOURCE=apr-util-${APR_UTIL_VERSION}

SQLITE_SOURCE=sqlite-amalgamation-$(echo $(printf %d%02d%02d%02d $(echo $SQLITE_VERSION | sed -e 's/\./ /g')))
SUBVERSION_SOURCE=subversion-${SUBVERSION_VERSION}

## GET SOURCE EXTEND LIB
wget https://www.zlib.net/${ZLIB_SOURCE}.tar.gz
wget https://github.com/libexpat/libexpat/releases/download/${EXPAT_PREFIX}/${EXPAT_SOURCE}.tar.gz

wget https://dist.apache.org/repos/dist/release/apr/${APR_SOURCE}.tar.gz
wget https://dist.apache.org/repos/dist/release/apr/${APR_UTIL_SOURCE}.tar.gz

wget https://www.sqlite.org/${SQLITE_VERSION_REL_YEAR}/${SQLITE_SOURCE}.zip
wget https://archive.apache.org/dist/subversion/${SUBVERSION_SOURCE}.tar.gz

## SET SVN-LIB
echo "/usr/local/subversion/lib" >> /etc/ld.so.conf.d/subversion.conf
export LD_LIBRARY_PATH=/usr/local/subversion/lib
export LD_RUN_PATH=/usr/local/subversion/lib


if [ "${BUILD_TARGET}" = "httpd_svn" ]; then
    # HTTPD INIT
    ## SET HTTPD-VERSION
    PCRE2_SOURCE=pcre2-${PCRE2_VERSION}
    HTTPD_SOURCE=httpd-${HTTPD_VERSION}
    LIBRESSL_SOURCE=libressl-${LIBRESSL_VERSION}

    ## GET HTTPD
    wget https://cdn.openbsd.org/pub/OpenBSD/LibreSSL/${LIBRESSL_SOURCE}.tar.gz
    wget https://github.com/PCRE2Project/pcre2/releases/download/${PCRE2_SOURCE}/${PCRE2_SOURCE}.tar.gz
    wget https://dist.apache.org/repos/dist/release/httpd/${HTTPD_SOURCE}.tar.gz

    ## SET HTTPD-LIB
    echo "/usr/local/httpd/lib" >> /etc/ld.so.conf.d/subversion.conf
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/httpd/lib
    export LD_RUN_PATH=${LD_RUN_PATH}:/usr/local/httpd/lib
fi

# LOAD LIBRARY
ldconfig
