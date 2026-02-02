# Shell Setup

Personal terminal configuration with zsh, Oh My Zsh, modern CLI tools, and Ghostty.

## Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/shell-setup.git ~/.shell-setup
cd ~/.shell-setup
./install.sh
```

## What's Included

### Zsh Configuration
- **Oh My Zsh** with spaceship theme
- **Plugins**: git, rails, zsh-autosuggestions, zsh-syntax-highlighting

### Modern CLI Tools
| Tool | Replaces | Description |
|------|----------|-------------|
| `eza` | `ls` | Modern ls with icons and git status |
| `bat` | `cat` | Syntax highlighting for files |
| `fd` | `find` | Faster, user-friendly find |
| `ripgrep` | `grep` | Faster grep |
| `dust` | `du` | Intuitive disk usage |
| `duf` | `df` | Better disk free |
| `btop` | `top` | Beautiful resource monitor |
| `fzf` | - | Fuzzy finder |
| `zoxide` | `cd` | Smarter directory jumping |
| `atuin` | history | Searchable shell history |
| `lazygit` | - | Git TUI |
| `lazydocker` | - | Docker TUI |

### Ghostty Terminal
- JetBrains Mono Nerd Font
- Catppuccin Mocha theme
- Custom cursor shaders (warp, ripple effects)
- Configured keybindings for splits/tabs

## Structure

```
shell-setup/
├── install.sh          # Main installer
├── zsh/
│   └── zshrc           # Zsh configuration
└── ghostty/
    ├── config          # Ghostty settings
    └── shaders/        # Cursor effect shaders
```

## Aliases

### File Operations
```bash
ls    # eza --icons --git
ll    # eza -la --icons --git
cat   # bat
find  # fd
grep  # rg
```

### Git
```bash
gs    # git status
gd    # git diff
gl    # git log --oneline --graph --all
gp    # git pull
gps   # git push
lg    # lazygit
```

### Docker
```bash
dc    # docker compose
dcu   # docker compose up -d
dcd   # docker compose down
dcl   # docker compose logs -f
ld    # lazydocker
```

## Local Overrides

Add machine-specific settings to `~/.zshrc.local` (not tracked in git):

```bash
# ~/.zshrc.local
export WORK_DIR="$HOME/work"
alias myproject="cd $WORK_DIR/myproject"
```

## Manual Steps

After installation:
1. Restart terminal or `source ~/.zshrc`
2. Set JetBrains Mono Nerd Font in Ghostty (should auto-apply)
3. Import Atuin history: `atuin import auto`

## Updating

```bash
cd ~/.shell-setup
git pull
./install.sh
```
