#!/bin/bash
# This script may be run standalone or source-d.

# If there is an executable repoactions.sh at the root of the git repo, AND the
# git repo is in the whitelist, we echo the name of the repo, followed by a
# vertical pipe, and then the path to repoactions.sh script. Otherwise, we echo
# nothing.

# if ! type _show_repoactions &>/dev/null; then
function _repoactions_usage() {
    echo "repoactions v0.0.11"
    echo "https://github.com/chaimleib/repoactions"
    echo "show_repoactions - echo reponame:path/to/repoactions.sh"
    echo "Usage: show_repoactions"
    echo "       show_repoactions [-v|-h]"
    echo ""
    echo "Options:"
    echo "  v|h    Show this message"
}

function _show_repoactions() {
    if [ -n "$1" ]; then
        _repoactions_usage
        return
    fi
    if ! [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]; then
        return
    fi

    projdir="$(git rev-parse --show-toplevel 2>/dev/null)"

    # Get the project id to determine whitelist status
    proj="$(git config --get remote.origin.url 2>/dev/null)"
    [ -n "$proj" ] || proj="$projdir"

    script="${projdir}/repoactions.sh"
    if ! [ -x "$script" ]; then
        return
    fi

    # Success!
    if _repoactions_is_listed "$proj" whitelist; then
        echo "${proj}|${script}"
        return
    fi

    # Not in whitelist
    if _repoactions_is_listed "$proj" ignore; then
        return
    fi

    # Not in ignore list
    cat << EOF >&2
repoactions: found $script
To enable it, add its project to the whitelist:

    echo "$proj" >> "$(_repoactions_config whitelist)"

Or, to silence this message without enabling the repoactions script:

    echo "$proj" >> "$(_repoactions_config ignore)"
EOF
}

function _repoactions_is_listed() {
    local projId="$1"
    local list="$(_repoactions_config $2)"
    if ! [ -f "$list" ]; then
        return 1
    fi
    while read -r line; do
        if [ "$line" == "$projId" ]; then
            return
        fi
    done < "$list"
    return 1
}

function _repoactions_config() {
    local config_dir="${HOME}/.config/repoactions"
    if [ -n "$1" ]; then
        echo "$config_dir/$1"
        return
    fi
    echo "$config_dir"
}
# fi

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # script is not being sourced; pass args to _show_repoactions
    _show_repoactions "$@"
fi

