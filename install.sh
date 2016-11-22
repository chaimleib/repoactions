#!/bin/bash

PREFIX="$1"
RC="$2"

if [ -z "$PREFIX" ]; then
    echo "Run this instead:"
    echo ""
    echo "  ./configure"
    echo "  make install"
fi

# ensure prefix paths
libexec="${PREFIX}/libexec/repoactions"
[ -d "$libexec" ] ||
    mkdir -p "$libexec"
[ -d "${PREFIX}/bin" ] ||
    mkdir -p "${PREFIX}/bin"

# ensure whitelist and ignore
config="${HOME}/.config/repoactions"
[ -d "$config" ] ||
    mkdir -p "$config"
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
. "$libexec/_repoactions.sh"
cmd='_repoactions'
[ -n "\$PROMPT_COMMAND" ] &&
    cmd="\$cmd; \${PROMPT_COMMAND}"
export PROMPT_COMMAND="\$cmd"
# END repoactions
EOF

echo "Note: To trigger the repoactions, few lines have been added to $profile."

