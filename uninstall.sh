#!/bin/bash

PREFIX="$1"
RC="$2"

if [ -z "$PREFIX" ]; then
    echo "Run this instead:"
    echo ""
    echo "  make uninstall"
fi

libexec="${PREFIX}/libexec/repoactions"
rm -rf "$libexec"
rm -f "${PREFIX}/bin/show_repoactions"
profile="$RC"
sed -i '' '/^# BEGIN repoactions/,/^# END repoactions/d' "$profile"

