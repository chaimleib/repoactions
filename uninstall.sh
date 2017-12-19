#!/bin/bash
set -e

PREFIX="$1"
profile="$2"

if [ -z "$PREFIX" ]; then
    echo "Run this instead:"
    echo ""
    echo "  make uninstall"
    exit 1
fi

libexec="${PREFIX}/libexec/repoactions"
rm -rf "$libexec"
rm -f "${PREFIX}/bin/show_repoactions"  # old name of repoactions
rm -f "${PREFIX}/bin/repoactions"
if [ -f "$profile" ]; then
    if ! sed -i '' '/^# BEGIN repoactions/,/^# END repoactions/d' "$profile"; then
	    echo "Nothing to change in $profile"
    fi
fi

