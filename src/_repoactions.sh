#!/bin/bash
# Must be sourced, and not run standalone.

# Upon cd-ing from outside into a git repo, runs the repoactions.sh script
# provided by show_repoactions, if any. Echoes absolutely nothing to standard
# output, since this is designed to be run every time the bash prompt is
# displayed. However, some output may be sent to stderr. For example:
#     export PROMPT_COMMAND='_repoactions'
function _repoactions() {
    result="$(show_repoactions)"
    if [ -z "$result" ]; then
        export REPOACTIONS_PROJ=
        return
    fi
    proj="${result%|*}"
    if [ "$REPOACTIONS_PROJ" == "$proj" ]; then
        return
    fi
    export REPOACTIONS_PROJ="$proj"
    script="${result#*|}"
    # shellcheck source=repoactions.sh
    source "$script"
}
