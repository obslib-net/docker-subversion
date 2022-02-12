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

/usr/local/subversion/bin/svnserve --daemon --foreground --root=${SUBVERSION_REPOS}

