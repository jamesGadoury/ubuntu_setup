#!/bin/bash

CONFIGS="./config_files"

BLUE=$(tput setaf 4)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

log_step () {
    printf "%40s\n" "${BLUE}$1${NORMAL}"
}

alert_user () {
    printf "%40s\n" "${GREEN}$1${NORMAL}"
}

log_step "Running update commands..."

sudo apt update && sudo apt upgrade -y

log_step "Installing zsh ..."
sudo apt install zsh -y

log_step "Installing oh-my-zsh ..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

log_step "Ensuring git default branch is main..."
git config --global init.defaultBranch main

log_step "Setting up git profile ..."
git config --global user.email gadouryjames@gmail.com
git config --global user.name "James Gadoury"

log_step "Setting up ssh keys..."
ssh-keygen -t ed25519 -C "gadouryjames@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

PROJECTS="$HOME/projects"
EXAMPLES="$HOME/examples"
DATA="$HOME/data"
BACKUPS="$HOME/backups"

log_step "Initializing directories..."
mkdir -p $PROJECTS
mkdir -p $EXAMPLES
mkdir -p $DATA
mkdir -p $BACKUPS

log_step "Initializing vimrc file..."
if [[ -f "$HOME/.vimrc" && ! -f "$BACKUPS/.vimrc" ]]; then
    printf "Backup up ~/.vimrc...\n"
    cp ~/.vimrc $BACKUPS
fi
cp "$CONFIGS/.vimrc" ~/.vimrc

log_step "Setting up .zshrc and aliases..."
if [ ! -f "$BACKUPS/.zshrc" ]; then
    printf "Backing up ~/.zshrc...\n"
    cp ~/.zshrc $BACKUPS
fi
cp "$CONFIGS/.aliases.zsh" $HOME
cp "$CONFIGS/.zshrc" $HOME

alert_user "Run: source ~/.zshrc to pick up updated changes!"