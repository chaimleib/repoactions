#!/bin/bash
set -e

PREFIX="$1"
profile="$2"

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

PROMPT_COMMAND='eval "\$(repoactions -e)";'"\${PROMPT_COMMAND}"
if [ -z "$profile" ]; then
	echo "We have not updated your shell's rc files."
	echo "Add this line to your .bashrc:"
	echo ""
	printf "    PROMPT_COMMAND=%q\n" "$PROMPT_COMMAND"
	echo ""
else
	# setup prompt command
	cat << EOF >> "$profile"
# BEGIN repoactions triggers
PROMPT_COMMAND='eval "\$(repoactions -e)";'"\${PROMPT_COMMAND}"
export PROMPT_COMMAND
# END repoactions
EOF

	echo "Note: repoactions sets itself up when you open your shell, so a few"
	echo "lines have been added to"
	echo "  $profile"
fi
