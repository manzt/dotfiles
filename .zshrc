# Path to oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  # zsh-autosuggestions
  fast-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export FZF_DEFAULT_COMMAND='rg --files'

# aliases
alias ls=exa
alias vim=nvim
alias path='echo -e ${PATH//:/\\n}'
alias tmux='tmux -2'
alias R=radian

# enable vi mode
# bindkey -v

# tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(fnm env)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
