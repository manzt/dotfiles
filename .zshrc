# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to vi
bindkey -v

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# --------------------
# Module configuration
# --------------------

#
# zsh-autosuggestions
#

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

#
# zsh-syntax-highlighting
#

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

zmodload -F zsh/terminfo +p:terminfo
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
  bindkey ${terminfo[kcuu1]} history-substring-search-up
  bindkey ${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# }}} End configuration added by Zim install

# ---------------------
# Personal config
# ---------------------

export EDITOR=nvim

# Aliases
alias vim=nvim
alias ls="eza --group-directories-first"
alias ll="ls -l"
alias l="ll -a"
alias tree="ls --tree"

# Tool initialization (conditional on availability)
(( ${+commands[fnm]} ))      && eval "$(fnm env --use-on-cd)"
(( ${+commands[starship]} )) && eval "$(starship init zsh)"
(( ${+commands[zoxide]} ))   && eval "$(zoxide init zsh)"
(( ${+commands[atuin]} ))    && eval "$(atuin init zsh --disable-up-arrow)"
(( ${+commands[gh]} ))       && eval "$(gh completion --shell zsh)"
(( ${+commands[jj]} ))       && source <(COMPLETE=zsh jj)

# Deno
[[ -d "$HOME/.deno/bin" ]] && export PATH="$HOME/.deno/bin:$PATH"

# uv
export UV_PYTHON_PREFERENCE=only-managed

# pnpm
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Claude
[[ -d "$HOME/.claude/local" ]] && export PATH="$HOME/.claude/local:$PATH"

# ---------------------
# Platform: macOS
# ---------------------

if [[ "$OSTYPE" == darwin* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export HOMEBREW_NO_AUTO_UPDATE=1

  # juv
  export JUV_JUPYTER=lab
  export JUV_RUN_MODE=managed
  export JUV_CELLMAGIC=1
  export JUV_PAGER=bat

  # opam
  [[ -r "$HOME/.opam/opam-init/init.zsh" ]] && source "$HOME/.opam/opam-init/init.zsh" &>/dev/null

  # juliaup
  [[ -d "$HOME/.juliaup/bin" ]] && export PATH="$HOME/.juliaup/bin:$PATH"

  # pixi
  [[ -d "$HOME/.pixi/bin" ]] && export PATH="$HOME/.pixi/bin:$PATH"

  # bun
  [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
  [[ -d "$HOME/.bun" ]] && export BUN_INSTALL="$HOME/.bun" && export PATH="$BUN_INSTALL/bin:$PATH"
fi

# ---------------------
# Platform: omarchy
# ---------------------

if [[ -d "$HOME/.local/share/omarchy" ]]; then
  export OMARCHY_PATH="$HOME/.local/share/omarchy"
  export PATH="$OMARCHY_PATH/bin:$PATH:$HOME/.local/bin"
  export BAT_THEME=ansi
  export SUDO_EDITOR="$EDITOR"

  # Source omarchy shell functions (worktrees, tmux layouts, compression, etc.)
  for f in "$OMARCHY_PATH"/default/bash/fns/*; do source "$f" 2>/dev/null; done

  # macOS compatibility aliases
  alias pbcopy='wl-copy'
  alias pbpaste='wl-paste'
  open() ( xdg-open "$@" >/dev/null 2>&1 & )

  # mise
  (( ${+commands[mise]} )) && eval "$(mise activate zsh)"

  # fzf
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
fi
