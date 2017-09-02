#!/bin/bash
set -e

PREFIX="$1"
RC="$2"

if [ -z "$PREFIX" ]; then
    echo "Run this instead:"
    echo ""
    echo "  ./configure"
    echo "  make install"
    exit 1
fi

# ensure prefix paths
libexec="${PREFIX}/libexec/repoactions"
if ! [ -d "$libexec" ]; then
    mkdir -p "$libexec"
fi
if ! [ -d "${PREFIX}/bin" ]; then
    mkdir -p "${PREFIX}/bin"
fi

# ensure whitelist and ignore
config="${HOME}/.config/repoactions"
if ! [ -d "$config" ]; then
    mkdir -p "$config"
fi
touch "${config}/whitelist"
touch "${config}/ignore"


# copy and link
cp -Rf ./src/*.sh ./README.md ./LICENSE "${libexec}/"
chmod +x "${libexec}"/*.sh
pushd "${PREFIX}/bin" >/dev/null
ln -s ../libexec/repoactions/show_repoactions.sh show_repoactions
popd >/dev/null

# setup prompt command
profile="$RC"
cat << EOF >> "$profile"
# BEGIN repoactions triggers
source "$libexec/_repoactions.sh"
PROMPT_COMMAND="_repoactions;\${PROMPT_COMMAND}"
export PROMPT_COMMAND
# END repoactions
EOF

echo "Note: repoactions sets itself up when you open your shell, so a few"
echo "lines have been added to"
echo "  $profile"
