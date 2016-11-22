#!/bin/bash
# This script may be run standalone or source-d.

# If there is an executable repoactions.sh at the root of the git repo, AND the
# git repo is in the whitelist, we echo the name of the repo, followed by a
# vertical pipe, and then the path to repoactions.sh script. Otherwise, we echo
# nothing.
if ! type _show_repoactions &>/dev/null; then
function _show_repoactions() {
    if [ -n "$1" ]; then
        echo "repoactions v0.0.7"
        echo "https://github.com/chaimleib/repoactions"
        echo "show_repoactions - echo reponame:path/to/repoactions.sh"
        echo "Usage: show_repoactions [-v|-h]"
        echo "Options:"
        echo "  v|h    Show this message"
        return
    fi
    [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ] ||
        return

    projdir="$(git rev-parse --show-toplevel 2>/dev/null)"

    proj="$(git config --get remote.origin.url 2>/dev/null)"
    [ -n "$proj" ] || proj="$projdir"

    script="${projdir}/repoactions.sh"
    [ -x "$script" ] ||
        return


    if _ra_is_listed "$proj" whitelist; then
        echo "${proj}|${script}"
        return
    fi
    config="${HOME}/.config/repoactions"
    _ra_is_listed "$proj" ignore ||
        cat << EOF >&2
repoactions: found $script
To enable it, add its project to the whitelist:

    echo "$proj" >> "$config/whitelist"

Or, to silence this message without enabling the repoactions script:

    echo "$proj" >> "$config/ignore"
EOF
}

function _ra_is_listed() {
    p="$1"
    f="${HOME}/.config/repoactions/$2"
    [ -f "$f" ] || return 1
    while read l; do
        [ "$l" == "$p" ] && return
    done < "$f"
    return 1
}
fi

_show_repoactions

