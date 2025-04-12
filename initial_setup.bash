#!/bin/bash
# Enable debugging and strict error handling
set -euo pipefail
set -x

# Log file in your home directory
log_file="$HOME/ubuntu24_setup.log"
exec > >(tee -a "$log_file") 2>&1

# Trap errors to print a custom message indicating the line number
trap 'echo "Error occurred at line ${LINENO}." >&2' ERR

echo "Starting Ubuntu 24 setup script at $(date)"

# Capture the directory from which the script was started.
ORIGINAL_DIR="$(pwd)"
echo "Original working directory: $ORIGINAL_DIR"

###############################################################################
# FUNCTION: install_firacode
# Description: Downloads the FiraCode zip from GitHub (via Nerd Fonts release), 
# extracts it, installs the TTF files if they’re not already installed, and updates 
# the font cache.
###############################################################################
install_firacode() {
    echo "Checking if FiraCode fonts are installed..."
    if fc-list | grep -qi "FiraCode"; then
        echo "FiraCode fonts already installed. Skipping."
        return 0
    fi

    echo "Installing FiraCode fonts..."
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    
    # Use pushd/popd to change directory temporarily.
    pushd "$tmp_dir" > /dev/null

    echo "Downloading FiraCode from $url"
    if ! wget "$url" -O FiraCode.zip; then
        echo "Error: Failed to download FiraCode zip from $url"
        exit 1
    fi

    echo "Extracting FiraCode zip..."
    if ! unzip -q FiraCode.zip; then
        echo "Error: Failed to unzip FiraCode.zip"
        exit 1
    fi

    mkdir -p "$HOME/.local/share/fonts/FiraCode"
    if [ -d ttf ]; then
        cp ttf/*.ttf "$HOME/.local/share/fonts/FiraCode/"
    else
        if ls *.ttf 1> /dev/null 2>&1; then
            cp *.ttf "$HOME/.local/share/fonts/FiraCode/"
        else
            echo "Warning: No TTF files found in the expected locations."
            exit 1
        fi
    fi

    echo "Refreshing font cache..."
    if ! fc-cache -f -v "$HOME/.local/share/fonts/FiraCode"; then
        echo "Error: Failed to update font cache."
        exit 1
    fi

    popd > /dev/null
    rm -rf "$tmp_dir"
    echo "FiraCode fonts installed."
}

###############################################################################
# FUNCTION: install_oh_my_zsh
# Description: Installs oh-my-zsh using its official installer if not already installed.
###############################################################################
install_oh_my_zsh() {
    echo "Checking if oh-my-zsh is installed..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh already installed. Skipping."
        return 0
    fi

    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
    echo "oh-my-zsh installation completed."
}

###############################################################################
# FUNCTION: install_oh_my_zsh_plugins
# Description: Installs oh-my-zsh custom plugins:
#              - zsh-autosuggestions
#              - zsh-syntax-highlighting
###############################################################################
install_oh_my_zsh_plugins() {
    echo "Installing oh-my-zsh custom plugins..."
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
    else
        echo "zsh-autosuggestions already installed."
    fi

    if [ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]; then
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
    else
        echo "zsh-syntax-highlighting already installed."
    fi
}

###############################################################################
# FUNCTION: install_tilix
# Description: Installs Tilix terminal emulator if not already present.
###############################################################################
install_tilix() {
    echo "Checking if Tilix is installed..."
    if command -v tilix >/dev/null 2>&1; then
        echo "Tilix already installed. Skipping."
        return 0
    fi

    echo "Installing Tilix..."
    sudo apt update
    sudo apt install -y tilix
    echo "Tilix installed."
    echo "Select Tilix as default terminal emulator:"
    sudo update-alternatives --config x-terminal-emulator
}

###############################################################################
# FUNCTION: setup_system_tools
# Description: Installs common development tools.
###############################################################################
setup_system_tools() {
    echo "Installing system tools: build-essential, vim, cmake, gettext, unzip..."
    sudo apt install -y build-essential vim cmake gettext unzip
}

###############################################################################
# FUNCTION: setup_vim
# Description: Writes a basic Vim configuration to ~/.vimrc if it doesn't exist.
###############################################################################
setup_vim() {
    echo "Checking if ~/.vimrc already exists..."
    if [ -f "$HOME/.vimrc" ]; then
        echo "~/.vimrc already exists. Skipping vim configuration."
        return 0
    fi

    echo "Setting up vim configuration..."
    cat << 'EOF' > "$HOME/.vimrc"
filetype plugin indent on
set syntax=on
set hidden
set backspace=indent,eol,start
set noswapfile
set number
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set textwidth=80
set nobackup
set hlsearch
set showmatch
EOF
    echo "Vim configuration written to ~/.vimrc"
}

###############################################################################
# FUNCTION: setup_neovim
# Description: Clones, builds, and installs Neovim if not already installed,
# and sets up the Neovim template.
###############################################################################
setup_neovim() {
    echo "Checking if Neovim is installed..."
    if command -v nvim >/dev/null 2>&1; then
        echo "Neovim already installed. Skipping building Neovim."
    else
        echo "Installing Neovim (release-0.10 branch)..."
        git clone https://github.com/neovim/neovim.git -b release-0.10 ~/neovim-source
        pushd ~/neovim-source > /dev/null
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
        popd > /dev/null
    fi

    echo "Checking if Neovim template is set up..."
    if [ -d "$HOME/.config/nvim" ]; then
        echo "Neovim template already exists. Skipping cloning template."
    else
        echo "Cloning Neovim template..."
        git clone https://github.com/jamesGadoury/nvim-template "$HOME/.config/nvim"
        pushd "$HOME/.config/nvim" > /dev/null
        chmod +x install_reqs.bash
        ./install_reqs.bash
        popd > /dev/null
    fi
    echo "Neovim setup completed."
}

###############################################################################
# FUNCTION: setup_git
# Description: Configures Git with your user name and email if not already set.
###############################################################################
setup_git() {
    echo "Checking git configuration..."
    current_email=$(git config --global user.email || echo "")
    current_name=$(git config --global user.name || echo "")
    if [[ "$current_email" == "gadouryjames@gmail.com" && "$current_name" == "James Gadoury" ]]; then
        echo "Git already configured. Skipping."
    else
        echo "Configuring git..."
        git config --global user.email "gadouryjames@gmail.com"
        git config --global user.name "James Gadoury"
    fi
}

###############################################################################
# FUNCTION: setup_ssh_keys
# Description: Generates an SSH key (if one doesn't already exist) for GitHub 
# and other server authentication. Uses the ed25519 algorithm and your GitHub email.
###############################################################################
setup_ssh_keys() {
    echo "Checking for existing SSH keys..."
    if [ ! -d "$HOME/.ssh" ]; then
        echo "No .ssh directory found. Creating one..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
    fi

    if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
        echo "An SSH key already exists. Skipping ssh-keygen."
    else
        echo "Generating a new SSH key using ed25519..."
        ssh-keygen -t ed25519 -C "gadouryjames@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
        echo "SSH key generated. Your public key is:"
        cat "$HOME/.ssh/id_ed25519.pub"
    fi
}

###############################################################################
# FUNCTION: setup_miniconda
# Description: Installs Miniconda if not already present, initializes it for zsh,
# and creates the default conda environment for machine learning.
###############################################################################
setup_miniconda() {
    echo "Checking if Miniconda is installed..."
    if [ -d "$HOME/miniconda3" ]; then
        echo "Miniconda already installed. Skipping."
    else
        echo "Installing Miniconda..."
        mkdir -p "$HOME/miniconda3"
        wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$HOME/miniconda3/miniconda.sh"
        bash "$HOME/miniconda3/miniconda.sh" -b -u -p "$HOME/miniconda3"
        rm -f "$HOME/miniconda3/miniconda.sh"
        "$HOME/miniconda3/bin/conda" init zsh
        echo "Miniconda installed and initialized for zsh."
    fi

    echo "Checking if the 'ml' conda environment exists..."
    if "$HOME/miniconda3/bin/conda" info --envs | grep -q "^ml\s"; then
        echo "'ml' conda environment already exists. Skipping environment creation."
    else
        echo "Setting up default 'ml' environment..."
        "$HOME/miniconda3/bin/conda" create -n ml -y
        "$HOME/miniconda3/bin/conda" install -n ml -y pytorch torchvision torchaudio pytorch-cuda=11.8 scikit-learn numpy scipy pandas matplotlib -c conda-forge -c pytorch -c nvidia
    fi
}

###############################################################################
# FUNCTION: install_vscode
# Description: Reminds the user to install Visual Studio Code manually.
###############################################################################
install_vscode() {
    echo "To install Visual Studio Code, please follow the instructions at:"
    echo "  https://code.visualstudio.com/docs/setup/linux"
    echo "After installation, reboot and enable settings sync with your GitHub account."
}

###############################################################################
# FUNCTION: setup_docker
# Description: Installs Docker Engine if not already present.
###############################################################################
setup_docker() {
    echo "Checking if Docker Engine is installed..."
    if command -v docker >/dev/null 2>&1; then
        echo "Docker already installed. Skipping."
        return 0
    fi

    echo "Installing Docker Engine..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
         | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "Docker Engine installed."
}

###############################################################################
# FUNCTION: setup_libraries
# Description: Installs additional libraries (Eigen, PCL, OpenCV, CLI11). 
###############################################################################
setup_libraries() {
    echo "Installing libraries: Eigen, PCL, OpenCV, CLI11..."
    sudo apt install -y libeigen3-dev libeigen3-doc
    sudo apt install -y libpcl-dev libpcl-doc pcl-tools
    sudo apt install -y libopencv-dev
    sudo apt install -y libcli11-dev
    echo "Libraries installed."
}

###############################################################################
# FUNCTION: install_systemclipboard
# Description: Installs the xsel system clipboard utility if not already installed.
###############################################################################
install_systemclipboard() {
    echo "Checking if xsel is installed..."
    if command -v xsel >/dev/null 2>&1; then
        echo "xsel already installed. Skipping."
        return 0
    fi

    echo "Installing system clipboard tool: xsel..."
    sudo apt install -y xsel
}

###############################################################################
# FUNCTION: install_zsh
# Description: Installs Zsh and required tools if not already installed.
###############################################################################
install_zsh() {
    echo "Checking if zsh is installed..."
    if command -v zsh >/dev/null 2>&1; then
        echo "zsh already installed. Skipping."
        return 0
    fi

    echo "Installing zsh, curl, and git..."
    sudo apt install -y zsh curl git
}

###############################################################################
# FUNCTION: configure_custom_keybindings
# Description: Configures GNOME custom keybindings for:
#   - Super+f opens the file explorer (Nautilus) to the home directory.
#   - Super+t opens the default terminal (Tilix).
###############################################################################
configure_custom_keybindings() {
    echo "Configuring custom keybindings..."
    local customKeybindingsPath="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
    local fileExplorerKeybindingPath="$customKeybindingsPath/custom0/"
    local terminalKeybindingPath="$customKeybindingsPath/custom1/"

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$fileExplorerKeybindingPath', '$terminalKeybindingPath']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$fileExplorerKeybindingPath" name 'Open Home'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$fileExplorerKeybindingPath" command "nautilus $HOME"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$fileExplorerKeybindingPath" binding '<Super>f'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$terminalKeybindingPath" name 'Open Terminal'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$terminalKeybindingPath" command "tilix"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$terminalKeybindingPath" binding '<Super>t'

    echo "Custom keybindings configured: <Super>f for file explorer and <Super>t for terminal."
}

###############################################################################
# FUNCTION: main
# Description: Calls the above functions in order to perform the full setup.
###############################################################################
main() {
    echo "Starting Ubuntu 24 automated setup..."

    # Update apt repositories early
    sudo apt update

    # Install system tools
    setup_system_tools

    # Install and set up zsh and oh-my-zsh
    install_zsh
    install_oh_my_zsh
    install_oh_my_zsh_plugins

    # Install Tilix terminal emulator
    install_tilix

    # Install FiraCode fonts
    install_firacode

    # Configure vim
    setup_vim

    # Install and configure Neovim
    setup_neovim

    # Set up Git configuration
    setup_git

    # Set up SSH keys for GitHub and other servers
    setup_ssh_keys

    # Install Miniconda and create default ML environment
    setup_miniconda

    # Install Docker Engine
    setup_docker

    # Install additional libraries
    setup_libraries

    # Install system clipboard tool
    install_systemclipboard

    # Configure custom GNOME keybindings
    configure_custom_keybindings

    # Remind user about VS Code installation
    install_vscode

    # Force update shell configuration files using the ORIGINAL_DIR variable
    cp -f "$ORIGINAL_DIR/.zshrc" ~/.zshrc
    cp -f "$ORIGINAL_DIR/.bash_aliases" ~/.bash_aliases

    echo "Ubuntu 24 setup complete at $(date)."
}

# Run the main function
main

