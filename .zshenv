# Start configuration added by Zim install {{{
#
# User configuration sourced by all invocations of the shell
#

# Define Zim location
: ${ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim}
# }}} End configuration added by Zim install

. "$HOME/.cargo/env"

. "$HOME/dev/miniforge3/bin"
. "$HOME/dev/miniforge3/etc/profile.d/conda.sh"

. "$HOME/.deno/bin"
