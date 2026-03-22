#!/usr/bin/env bash
#
# bootstrap-omarchy.sh
#
# Sets up personal dotfiles on top of an omarchy installation.
# Run this once on a fresh omarchy machine.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/manzt/dotfiles/main/bootstrap-omarchy.sh | bash
#   # or just: bash bootstrap-omarchy.sh
#
set -euo pipefail

DOTFILES_REPO="git@github.com:manzt/dotfiles.git"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }

# -------------------------------------------------------
# 1. Install packages
# -------------------------------------------------------
info "Installing packages..."
sudo pacman -S --needed --noconfirm \
    zsh \
    git-delta \
    eza \
    starship \
    zoxide \
    atuin \
    fd \
    ripgrep \
    fzf \
    jujutsu

# bob (neovim version manager)
if ! command -v bob &>/dev/null; then
    if command -v cargo &>/dev/null; then
        info "Installing bob-nvim via cargo..."
        cargo install bob-nvim
    else
        warn "cargo not found — skipping bob. Install: https://github.com/MordechaiHadad/bob"
    fi
fi

# fnm (node version manager)
if ! command -v fnm &>/dev/null; then
    info "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

# deno
if ! command -v deno &>/dev/null; then
    info "Installing deno..."
    curl -fsSL https://deno.land/install.sh | sh
fi

ok "Packages installed"

# -------------------------------------------------------
# 2. Set default shell to zsh
# -------------------------------------------------------
info "Setting default shell to zsh..."
ZSH_PATH="$(which zsh)"
if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH"
    ok "Default shell changed to zsh (takes effect on next login)"
else
    ok "Already using zsh"
fi

# -------------------------------------------------------
# 3. Clone dotfiles into ~
# -------------------------------------------------------
info "Setting up dotfiles in ~..."
cd "$HOME"

if [[ -d .git ]]; then
    ok "Dotfiles repo already initialized"
else
    git init
    git remote add origin "$DOTFILES_REPO"
    git fetch origin main

    # Back up any files that would be overwritten
    mkdir -p "$BACKUP_DIR"
    backed_up=0
    while IFS= read -r f; do
        [[ -e "$f" ]] || continue
        mkdir -p "$BACKUP_DIR/$(dirname "$f")"
        cp -a "$f" "$BACKUP_DIR/$f"
        warn "Backed up: $f"
        backed_up=1
    done < <(git ls-tree -r --name-only origin/main)

    git checkout -f origin/main
    git branch -M main
    git branch --set-upstream-to=origin/main main

    if (( backed_up )); then
        ok "Dotfiles checked out (conflicts backed up to $BACKUP_DIR)"
    else
        ok "Dotfiles checked out"
    fi
fi

# -------------------------------------------------------
# 4. Set up Zim (zsh framework)
# -------------------------------------------------------
info "Setting up Zim..."
ZIM_HOME="${HOME}/.zim"
if [[ ! -e "${ZIM_HOME}/zimfw.zsh" ]]; then
    curl -fsSL --create-dirs -o "${ZIM_HOME}/zimfw.zsh" \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    ok "Zim downloaded (modules install on first zsh launch)"
else
    ok "Zim already installed"
fi

# -------------------------------------------------------
# 5. Set up neovim
# -------------------------------------------------------
info "Setting up neovim..."

# Install neovim via bob if needed
if command -v bob &>/dev/null && ! command -v nvim &>/dev/null; then
    bob install stable
    bob use stable
    ok "Neovim installed via bob"
fi

NVIM_DIR="$HOME/.config/nvim"
NVIM_OMARCHY="$HOME/.config/nvim.omarchy"

# Back up omarchy's nvim config so we can copy files from it
if [[ -d "$NVIM_DIR" && ! -d "$NVIM_OMARCHY" ]]; then
    if grep -q "config.lazy" "$NVIM_DIR/init.lua" 2>/dev/null; then
        mv "$NVIM_DIR" "$NVIM_OMARCHY"
        git checkout HEAD -- .config/nvim/
        ok "Omarchy nvim backed up to $NVIM_OMARCHY"
    fi
fi

# Copy omarchy theme files into personal nvim config (not tracked by git)
if [[ -d "$NVIM_OMARCHY" ]]; then
    mkdir -p "$NVIM_DIR/plugin/after"
    mkdir -p "$NVIM_DIR/lua/plugins"

    cp -v "$NVIM_OMARCHY/plugin/after/transparency.lua" \
          "$NVIM_DIR/plugin/after/" 2>/dev/null || true

    cp -v "$NVIM_OMARCHY/lua/plugins/omarchy-theme-hotreload.lua" \
          "$NVIM_DIR/lua/plugins/" 2>/dev/null || true

    ok "Omarchy theme integration copied into nvim config"
fi

# -------------------------------------------------------
# 6. Patch Hyprland bindings
# -------------------------------------------------------
info "Patching Hyprland bindings..."
BINDINGS="$HOME/.config/hypr/bindings.conf"
if [[ -f "$BINDINGS" ]] && ! grep -q "Vim-style focus" "$BINDINGS"; then
    cat >> "$BINDINGS" << 'HYPR_EOF'

# Vim-style focus (override arrow key defaults + conflicting defaults)
unbind = SUPER, LEFT
unbind = SUPER, RIGHT
unbind = SUPER, UP
unbind = SUPER, DOWN
unbind = SUPER, H
unbind = SUPER, J
unbind = SUPER, K
unbind = SUPER, L
bindd = SUPER, H, Move window focus left, movefocus, l
bindd = SUPER, L, Move window focus right, movefocus, r
bindd = SUPER, K, Move window focus up, movefocus, u
bindd = SUPER, J, Move window focus down, movefocus, d
bindd = SUPER, semicolon, Toggle window split, layoutmsg, togglesplit
bindd = SUPER SHIFT, semicolon, Toggle workspace layout, exec, omarchy-hyprland-workspace-layout-toggle

# Free up comma keys (notifications) and rebind
unbind = SUPER, comma
unbind = SUPER ALT, comma
unbind = SUPER CTRL, comma
unbind = SUPER SHIFT, comma
unbind = SUPER SHIFT ALT, comma
bindd = SUPER, comma, Show key bindings, exec, omarchy-menu-keybindings
HYPR_EOF
    ok "Hyprland vim bindings applied"
else
    ok "Hyprland bindings already patched"
fi

# -------------------------------------------------------
# 7. Colocate jj
# -------------------------------------------------------
if command -v jj &>/dev/null && [[ ! -d .jj ]]; then
    info "Setting up jj (colocated)..."
    jj git init --colocate
    jj bookmark track main --remote=origin 2>/dev/null || true
    ok "jj colocated repo initialized"
fi

# -------------------------------------------------------
# Done
# -------------------------------------------------------
echo ""
info "All done! Next steps:"
echo "  1. Log out and back in (or run 'zsh') to start using zsh"
echo "  2. On first zsh launch, Zim will install its modules"
echo "  3. Run 'nvim' to let lazy.nvim install plugins"
