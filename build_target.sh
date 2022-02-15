
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

## SUBVERSION
SQLITE_SOURCE=sqlite-amalgamation-$(echo $(printf %d%02d%02d%02d $(echo $SQLITE_VERSION | sed -e 's/\./ /g')))
SUBVERSION_SOURCE=subversion-${SUBVERSION_VERSION}

