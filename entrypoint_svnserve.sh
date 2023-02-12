#!/usr/bin/env bash

if [[ -z "${SUBVERSION_REPOS}" ]]; then
    SUBVERSION_REPOS=/var/svn/repos
fi

su - svn

/usr/local/subversion/bin/svnserve --daemon --foreground --root=${SUBVERSION_REPOS}
