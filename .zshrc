# NOTE: Keep this at beginning in case we want to enable profiling 
# zmodload zsh/zprof

# Only run these settings in interactive shells.
[[ $- != *i* ]] && return

#########################
# Environment Variables
#########################
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

#########################
# History Configuration
#########################
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history share_history extended_history

#########################
# Useful Shell Options
#########################
setopt nocaseglob       # Case-insensitive globbing
setopt correct          # Auto-correct commands
setopt no_beep          # Disable terminal bell

#########################
# Preload Optimized Completions
#########################
# Preload compinit with -U to skip insecure-directory checks and -C to use cached dumps.
# This ensures oh-my-zsh won't reinitialize completions and reduces startup overhead.
autoload -Uz compinit && compinit -U -C

#########################
# Oh-My-Zsh Settings & Plugins
#########################
# Define location of oh-my-zsh.
export ZSH="$HOME/.oh-my-zsh"
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true
# Already using preloaded compinit—disable additional compfix attempts.
DISABLE_COMPFIX=true

# Set your preferred theme and plugin list.
ZSH_THEME="fino-time"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Source the main oh-my-zsh script.
source "$ZSH/oh-my-zsh.sh"

#########################
# Colors & Output
#########################
autoload -U colors && colors
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

#########################
# Additional Customizations
#########################
# Source fzf support if installed.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Extend PATH with additional directories.
export PATH="$HOME/miniconda3/bin:$PATH"

# Load additional alias definitions if they exist.
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# NOTE: Keep this at end in case we want to profile loading
# zprof

