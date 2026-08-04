#!/usr/bin/env bash

set -euo pipefail

# Set default repository path if not provided
SUBVERSION_REPOS="${SUBVERSION_REPOS:-/var/svn/repos}"

# Validate repository path exists
if [[ ! -d "${SUBVERSION_REPOS}" ]]; then
    echo "Error: Repository path does not exist: ${SUBVERSION_REPOS}" >&2
    exit 1
fi

exec /usr/local/subversion/bin/svnserve --daemon --foreground --root="${SUBVERSION_REPOS}"
