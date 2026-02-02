#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ============================================================
# Homebrew
# ============================================================
install_homebrew() {
    if command -v brew &> /dev/null; then
        success "Homebrew already installed"
        return
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to path for this session
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    success "Homebrew installed"
}

# ============================================================
# Oh My Zsh
# ============================================================
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        success "Oh My Zsh already installed"
        return
    fi

    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh installed"
}

# ============================================================
# Zsh Plugins
# ============================================================
install_zsh_plugins() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        success "zsh-autosuggestions installed"
    else
        success "zsh-autosuggestions already installed"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        success "zsh-syntax-highlighting installed"
    else
        success "zsh-syntax-highlighting already installed"
    fi

    # spaceship-prompt
    if [ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]; then
        info "Installing spaceship-prompt..."
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
        ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
        success "spaceship-prompt installed"
    else
        success "spaceship-prompt already installed"
    fi

    # spaceship-ember
    if [ ! -d "$ZSH_CUSTOM/plugins/spaceship-ember" ]; then
        info "Installing spaceship-ember..."
        git clone https://github.com/spaceship-prompt/spaceship-ember.git "$ZSH_CUSTOM/plugins/spaceship-ember"
        success "spaceship-ember installed"
    else
        success "spaceship-ember already installed"
    fi

    # spaceship-vi-mode
    if [ ! -d "$ZSH_CUSTOM/plugins/spaceship-vi-mode" ]; then
        info "Installing spaceship-vi-mode..."
        git clone https://github.com/spaceship-prompt/spaceship-vi-mode.git "$ZSH_CUSTOM/plugins/spaceship-vi-mode"
        success "spaceship-vi-mode installed"
    else
        success "spaceship-vi-mode already installed"
    fi
}

# ============================================================
# CLI Tools via Homebrew
# ============================================================
install_cli_tools() {
    info "Installing CLI tools via Homebrew..."

    local tools=(
        # Modern replacements
        eza           # ls replacement
        bat           # cat replacement
        fd            # find replacement
        ripgrep       # grep replacement
        dust          # du replacement
        duf           # df replacement
        btop          # top replacement

        # Productivity
        fzf           # fuzzy finder
        zoxide        # smarter cd
        atuin         # shell history
        lazygit       # git TUI
        lazydocker    # docker TUI

        # Fonts
        font-jetbrains-mono-nerd-font
    )

    brew tap homebrew/cask-fonts 2>/dev/null || true

    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            success "$tool already installed"
        else
            info "Installing $tool..."
            brew install "$tool" || warn "Failed to install $tool"
        fi
    done

    # Setup fzf keybindings
    if [ -f "$(brew --prefix)/opt/fzf/install" ]; then
        info "Setting up fzf keybindings..."
        "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
    fi

    success "CLI tools installed"
}

# ============================================================
# Ghostty
# ============================================================
install_ghostty() {
    if ! command -v ghostty &> /dev/null && [ ! -d "/Applications/Ghostty.app" ]; then
        info "Installing Ghostty..."
        brew install --cask ghostty || warn "Failed to install Ghostty via brew"
    else
        success "Ghostty already installed"
    fi
}

# ============================================================
# Link Configurations
# ============================================================
backup_and_link() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backing up existing $dest to $backup"
        mv "$dest" "$backup"
    fi

    if [ -L "$dest" ]; then
        rm "$dest"
    fi

    ln -sf "$src" "$dest"
    success "Linked $dest -> $src"
}

link_configs() {
    info "Linking configuration files..."

    # Zsh
    backup_and_link "$SCRIPT_DIR/zsh/zshrc" "$HOME/.zshrc"

    # Ghostty
    mkdir -p "$HOME/.config/ghostty"
    backup_and_link "$SCRIPT_DIR/ghostty/config" "$HOME/.config/ghostty/config"

    # Ghostty shaders (copy directory contents, don't symlink)
    if [ -d "$SCRIPT_DIR/ghostty/shaders" ]; then
        mkdir -p "$HOME/.config/ghostty/shaders"
        cp -r "$SCRIPT_DIR/ghostty/shaders/"* "$HOME/.config/ghostty/shaders/"
        success "Copied ghostty shaders"
    fi
}

# ============================================================
# Main
# ============================================================
main() {
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  Shell Setup Installation${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""

    # Check macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        error "This script currently only supports macOS"
    fi

    install_homebrew
    install_oh_my_zsh
    install_zsh_plugins
    install_cli_tools
    install_ghostty
    link_configs

    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    info "Restart your terminal or run: source ~/.zshrc"
    echo ""
}

main "$@"
