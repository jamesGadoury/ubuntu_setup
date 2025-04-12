# Only run these settings in interactive shells.
[[ $- != *i* ]] && return

#########################
# Environment Variables
#########################
# Set locale for proper character encoding.
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Increase and share history across sessions.
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history
setopt extended_history  # Save timestamps along with each history entry

# Useful shell options.
setopt nocaseglob       # Case-insensitive globbing
setopt correct          # Auto-correct commands
setopt no_beep          # Disable terminal bell

#########################
# Oh-My-Zsh Settings
#########################
# Define location of oh-my-zsh.
export ZSH="$HOME/.oh-my-zsh"

# Disable auto-update and compinit security checks to improve startup speed.
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true
DISABLE_COMPFIX=true

# Set your oh-my-zsh theme to "fino-time".
ZSH_THEME="fino-time"

# Specify a minimal and focused plugin list.
# Note: Ensure plugins like "zsh-autosuggestions" and "zsh-syntax-highlighting"
#       are installed (e.g. in $ZSH_CUSTOM/plugins/) if not provided by default.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

#########################
# Load Oh-My-Zsh
#########################
# Source the main oh-my-zsh script.
source "$ZSH/oh-my-zsh.sh"

#########################
# Completions Optimization
#########################
# Cache the completion dump for faster startup.
# If the dump is missing or outdated relative to this file, regenerate it.
if [[ ! -f ~/.zcompdump ]] || [[ ~/.zcompdump -ot ~/.zshrc ]]; then
  rm -f ~/.zcompdump*
  autoload -Uz compinit && compinit -C
else
  autoload -Uz compinit && compinit -C
fi

#########################
# Aliases & Functions
#########################
# Common alias definitions.
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gst='git status'
alias gco='git checkout'
alias gbr='git branch'
alias gl='git log --oneline --graph --decorate'
alias cls='clear'

# Function: Update oh-my-zsh manually.
omz_update() {
  echo "Updating oh-my-zsh..."
  env ZSH="$ZSH" "$ZSH/tools/upgrade.sh"
}

# Function: Open .zshrc in your preferred editor.
ze() {
  ${EDITOR:-vim} ~/.zshrc
}

#########################
# Additional Customizations
#########################
# Enable colors for commands and terminal output.
autoload -U colors && colors
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# fzf support (if installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/miniconda3/bin:$PATH"

source ~/.bash_aliases
