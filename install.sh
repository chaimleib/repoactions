#!/bin/bash
set -e

PREFIX="$1"
profile="$2"

# setup prompt command
function repoactions_triggers() {
    cat << 'EOF'
# BEGIN repoactions triggers
if [[ -n "$PROMPT_COMMAND" ]] && [[ "$PROMPT_COMMAND" != *; ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND}"';eval "$(repoactions -e)"'
else
    PROMPT_COMMAND="${PROMPT_COMMAND}"'eval "$(repoactions -e)"'
fi
export PROMPT_COMMAND
# END repoactions
EOF
}

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

# copy and link
cp -Rf ./src/*.sh ./README.md ./LICENSE "${libexec}/"
chmod +x "${libexec}"/*.sh
pushd "${PREFIX}/bin" >/dev/null
ln -s ../libexec/repoactions/repoactions.sh repoactions
popd >/dev/null

if [ -z "$profile" ]; then
	echo "We have not updated your shell's rc files."
	echo "Add these lines to your .bashrc, or equivalent:"
	echo ""
    repoactions_triggers
else
    repoactions_triggers >> "$profile"
    echo "Note: repoactions sets itself up when you open your shell, so a few"
    echo "lines have been added to"
    echo "  $profile"
fi

