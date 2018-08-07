#!/bin/bash
# This script should be run standalone, but can be source-d for debugging.

function _repoactions_usage() {
    echo "repoactions v0.3.3"
    echo "https://github.com/chaimleib/repoactions"
    echo "repoactions - run script on entering a git repo"
    echo "Usage: $_repoactions_script_name -[cdehsSwWvz]"
    echo ""
    echo "Options:"
    echo "  c      Create config files, if not present"
    echo "  d      Prints doctor's messages for debugging issues with repoactions.sh"
    echo "  h, v   Show this message"
    echo "  e      Echoes a command to source this repo's repoactions.sh, if it is"
    echo "             whitelisted and executable"
    echo "  s      Silence config hints about this repo's repoactions.sh"
    echo "  S      Un-silence config hints"
    echo "  w      Whitelist this repo's repoactions.sh and auto-run it when cd-ing in"
    echo "  W      Un-whitelist this repo"
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
        _repoactions_echo_run_command
        return "$?"
        ;;
    '-d')
        _repoactions_doctor
        return "$?"
        ;;
    '-s')
        _repoactions_silence
        return "$?"
        ;;
    '-S')
        _repoactions_unlist silence
        return "$?"
        ;;
    '-w')
        _repoactions_whitelist
        return "$?"
        ;;
    '-W')
        _repoactions_unlist whitelist
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

    if ! projdir="$(_repoactions_proj_dir)"; then
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
    echo "Silencing hints about repoactions.sh of $proj"
}

function _repoactions_whitelist() {
    local projdir
    local proj
    local script

    if ! projdir="$(_repoactions_proj_dir)"; then
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

function _repoactions_hint() {
    local script
    script="$1"
    cat << EOF
repoactions: found $script
To enable it, add its project to the whitelist:

    $_repoactions_script_name -w

Or, to silence this message without enabling the repoactions script:

    $_repoactions_script_name -s

EOF
}

function _repoactions_doctor() {
    local projdir
    local proj
    local script
    local silenced

    echo "## Repoactions doctor ##"
    echo ""

    if ! projdir="$(_repoactions_proj_dir)"; then
        echo "Not inside a git repo"
        return 1
    fi
    echo "Project dir: $projdir"

    # Get the project id to determine whitelist status
    proj="$(_repoactions_proj_id "$projdir")"
    echo "Project ID: $proj"

    script="${projdir}/repoactions.sh"
    if ! [ -f "$script" ]; then
        echo "Script: does not exist"
        echo "Try creating"
        echo "    $script"
        echo ""
        echo "Then, make sure it is executable with"
        echo "    chmod +x $script"
        echo ""
        echo "When repoactions get run for this repo, that script will be source-d."
        echo ""
        return 1
    fi
    echo "Script: $script"
    echo ""
    _repoactions_is_listed "$proj" silence
    silenced="$?"
    if [ "$silenced" -eq 0 ]; then
        echo "Hints: silenced"
    else
        echo "Hints: enabled"
    fi
    if ! [ -x "$script" ]; then
        echo "Executable: no"
        echo "Try running"
        echo "    chmod +x $script"
        echo ""
        return 1
    else
        echo "Executable: yes"
    fi

    # Success!
    if _repoactions_is_listed "$proj" whitelist; then
        echo "Whitelisted: yes"
    else
        echo "Whitelisted: no"
        echo "To enable this script, run"
        echo "    $_repoactions_script_name -w"
        echo ""
        if [ "$silenced" -ne 0 ]; then
            echo "Alternatively, if you want to silence hints about this repo, run"
            echo "    $_repoactions_script_name -s"
            echo ""
        fi
        return 1
    fi
    echo ""
    echo "## Repoactions is enabled for this git repo ##"
    echo ""
}

function _repoactions_echo_run_command() {
    local projdir
    local proj
    local script

    if ! projdir="$(_repoactions_proj_dir)"; then
        # Not in git repo
        echo "export REPOACTIONS_PROJ="
        return
    fi

    # Get the project id to determine whitelist status
    proj="$(_repoactions_proj_id "$projdir")"

    # Skip sourcing repoactions.sh if already in the repo tree
    if [ "$proj" == "$REPOACTIONS_PROJ" ]; then
        return
    fi

    script="${projdir}/repoactions.sh"
    if ! [ -x "$script" ]; then
        # Script not enabled; must be executable
        echo "export REPOACTIONS_PROJ="
        return
    fi

    # Success!
    if _repoactions_is_listed "$proj" whitelist; then
        printf 'REPOACTIONS_PROJ=%q\n' "$proj"
        echo "export REPOACTIONS_PROJ"
        printf 'source %q\n' "$script"
        return
    fi
    # Not in whitelist

    if ! _repoactions_is_listed "$proj" silence; then
        _repoactions_hint "$script" >&2
    fi
    printf 'REPOACTIONS_PROJ=%q\n' "$proj"
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

function _repoactions_unlist() {
    local projId
    local listName
    local list
    local removed
    local projdir
    listName="$1"

    if ! projdir="$(_repoactions_proj_dir)"; then
        echo "Error: not inside a git repo" >&2
        return 1
    fi
    projId="$(_repoactions_proj_id "$projdir")"
    list="$(_repoactions_config "$listName")"
    if ! [ -f "$list" ]; then
        return 1
    fi
    while read -r line; do
        if [ "$line" == "$projId" ]; then
            removed=y
            continue
        fi
        echo "$line"
    done < "$list" > "${list}.temp"
    if [ "$removed" == "y" ]; then
        mv "${list}.temp" "$list"
        echo "Unlisted this repo from $listName file" >&2
    else
        echo "Already not listed in $listName file" >&2
    fi
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


# for documentation and messages only!
_repoactions_script_name="${BASH_SOURCE[0]}"
the_which="$(which repoactions)" &&
    [[ "$the_which" == "$_repoactions_script_name" ]] &&
    _disable_abs_script_name=y
[[ -L "$the_which" ]] &&
    [[ "$(readlink "$the_which")" == "$_repoactions_script_name" ]] &&
    _disable_abs_script_name=y
[[ -n "$_disable_abs_script_name" ]] && _repoactions_script_name="repoactions"
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # script is not being sourced; pass args to _repoactions_main
    _repoactions_main "$@"
    exit "$?"
fi

