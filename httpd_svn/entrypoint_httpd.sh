#!/usr/bin/env bash

set -euo pipefail

exec /usr/local/httpd/bin/httpd -DFOREGROUND

