#!/bin/bash
# This script should be run standalone, but can be source-d for debugging.

function _repoactions_usage() {
    echo "repoactions v0.0.11"
    echo "https://github.com/chaimleib/repoactions"
    echo "repoactions - run script on entering a git repo"
    echo "Usage: $_repoactions_script_name -[cheswvz]"
    echo ""
    echo "Options:"
    echo "  c      Create config files, if not present"
    echo "  e      Echoes projId|path/to/proj/repoactions.sh"
    echo "  h, v   Show this message"
    echo "  s      Silence config hints about this repo's repoactions.sh"
    echo "  w      Whitelist this repo's repoactions.sh and auto-run it when cd-ing in"
    echo "  z      Zap (delete) config files"
    echo ""
}

function _repoactions_main() {
    if ! [ -n "$1" ]; then
        _repoactions_usage
        return
    fi
    case "$1" in
    '-e')
        _repoactions_config_line
        return "$?"
        ;;
    '-s')
        _repoactions_silence
        return "$?"
        ;;
    '-w')
        _repoactions_whitelist
        return "$?"
        ;;
    '-c')
        _repoactions_create_configs
        return "$?"
        ;;
    '-z')
        _repoactions_zap_configs
        return "$?"
        ;;
    '-'[hv])
        _repoactions_usage
        return
        ;;
    *)
        _repoactions_usage >&2
        return 1
        ;;
    esac
}

function _repoactions_proj_dir() {
    if ! [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]; then
        return 1
    fi
    git rev-parse --show-toplevel 2>/dev/null
    return "$?"
}

function _repoactions_proj_id() {
    local projDir
    local projUrl
    projDir="$1"
    projUrl="$(git config --get remote.origin.url 2>/dev/null)"
    if [ -z "$projUrl" ]; then
        echo "$projDir"
    fi
    echo "$projUrl"
}

function _repoactions_silence() {
    local projdir
    local proj
    projdir="$(_repoactions_proj_dir)"
    if [ "$?" -ne 0 ]; then
        echo "Error: not inside a git repo" >&2
        return 1
    fi
    proj="$(_repoactions_proj_id "$projdir")"

    # Already listed
    if _repoactions_is_listed "$proj" silence; then
        echo "Already silenced hints about repoactions.sh of $proj"
        return
    fi
    _repoactions_create_configs
    echo "$proj" >> "$(_repoactions_config silence)"
    echo "Sliencing hints about repoactions.sh of $proj"
}

function _repoactions_whitelist() {
    local projdir
    local proj
    local script
    projdir="$(_repoactions_proj_dir)"
    if [ "$?" -ne 0 ]; then
        echo "Error: not inside a git repo" >&2
        return 1
    fi
    proj="$(_repoactions_proj_id "$projdir")"

    script="${projdir}/repoactions.sh"
    if ! [ -x "$script" ]; then
        echo "Warning: to enable, execute permission must be set on $script" >&2
    fi

    # Success!
    if _repoactions_is_listed "$proj" whitelist; then
        echo "Already whitelisted repoactions.sh of $proj"
        return
    fi
    _repoactions_create_configs
    echo "$proj" >> "$(_repoactions_config whitelist)"
    echo "Whitelisting repoactions.sh of $proj"
}

function _repoactions_config_line() {
    local projdir
    local proj
    local script

    projdir="$(_repoactions_proj_dir)"
    if [ "$?" -ne 0 ]; then
        echo "Error: not inside a git repo" >&2
        return 1
    fi

    # Get the project id to determine whitelist status
    proj="$(_repoactions_proj_id "$projdir")"

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
    if _repoactions_is_listed "$proj" silence; then
        return
    fi

    # Not in silence list
    cat << EOF >&2
repoactions: found $script
To enable it, add its project to the whitelist:

    $_repoactions_script_name -w

Or, to silence this message without enabling the repoactions script:

    $_repoactions_script_name -s

EOF
}

function _repoactions_is_listed() {
    local projId
    local list

    projId="$1"
    list="$(_repoactions_config "$2")"
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
    local config_dir

    config_dir="${HOME}/.config/repoactions"
    if [ -n "$1" ]; then
        echo "$config_dir/$1"
        return
    fi
    echo "$config_dir"
}

function _repoactions_create_configs() {
    local cfgDir
    local whitelist
    local silence

    cfgDir="$(_repoactions_config)"
    if ! [ -d "$cfgDir" ]; then
        echo "Creating the config directory ($cfgDir) ..."
        mkdir -p "$cfgDir"
    fi
    whitelist="$(_repoactions_config whitelist)"
    if ! [ -f "$whitelist" ]; then
        echo "Creating a blank whitelist ($whitelist) ..."
        touch "$whitelist"
    fi
    silence="$(_repoactions_config silence)"
    if ! [ -f "$silence" ]; then
        echo "Creating a blank silence file ($silence) ..."
        touch "$silence"
    fi
    echo "Configs are present"
}

function _repoactions_zap_configs() {
    local cfgDir

    cfgDir="$(_repoactions_config)"
    if ! [ -d "$cfgDir" ]; then
        echo "No configs to delete" >&2
        return 1
    fi
    printf '%s' "Really delete repoactions configs? [y/N] "
    while read -r line; do
        case "$line" in
        [yY]*)
            break
            ;;
        [nN]*)
            echo "Canceled."
            return 1
            ;;
        '')
            echo "Canceled."
            return 1
            ;;
        *)
            echo "Answer with 'y' or 'n'"
            ;;
        esac
        printf '%s' "Really delete repoactions configs? [y/N] "
    done
    echo "Deleting config directory ($cfgDir) ..."
    rm -rf "$cfgDir"
    echo "Configs deleted"
}


_repoactions_script_name="${BASH_SOURCE[0]}"
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # script is not being sourced; pass args to _repoactions_main
    _repoactions_main "$@"
    exit "$?"
fi
