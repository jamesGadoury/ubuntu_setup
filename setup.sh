#!/bin/bash

./doUpdates.sh

sudo apt install vim

./init-alias.sh
./setup-git.sh
./init-vimrc.sh
./install-dracula-vim.sh
./install-vimpolyglot.sh
