# User configuration sourced by all invocations of the shell

# Zim
: ${ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim}

# Cargo
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Deno
[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"

# Bob (neovim version manager)
[[ -f "$HOME/.local/share/bob/env/env.sh" ]] && . "$HOME/.local/share/bob/env/env.sh"
