#!/usr/bin/env bash

if [[ -z "${SUBVERSION_REPOS}" ]]; then
    SUBVERSION_REPOS=/var/svn/repos
fi
if [[ ! -d ${SUBVERSION_REPOS} ]]; then
    mkdir -p ${SUBVERSION_REPOS}
    /usr/local/subversion/bin/svnadmin create ${SUBVERSION_REPOS}
    cp /usr/local/httpd/conf/httpd-svn.conf ${SUBVERSION_REPOS}/conf/httpd-svn.conf
    chown -R subversion:subversion ${SUBVERSION_REPOS}
fi

if [[ ! -e /usr/local/httpd/conf/server.crt ]]; then
    /usr/local/httpd/bin/openssl req -x509 -sha256 -nodes -newkey rsa:2048 -keyout /usr/local/httpd/conf/server.key -out /usr/local/httpd/conf/server.crt -days 36500 -subj /CN=localhost
fi


rm -f /usr/local/httpd/logs/httpd.pid

/usr/local/httpd/bin/httpd -DFOREGROUND

