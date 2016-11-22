#!/bin/bash

PREFIX="$1"
libexec="${PREFIX}/libexec/repoactions"
rm -rf "$libexec"
rm -f "${PREFIX}/bin/show_repoactions"
profile="${HOME}/.profile"
sed -i '' '/^# BEGIN repoactions/,/^# END repoactions/d' "$profile"

