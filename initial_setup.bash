#!/bin/bash
# Enable debugging and strict error handling
set -euo pipefail
set -x

# Log file in your home directory
log_file="$HOME/ubuntu24_setup.log"
exec > >(tee -a "$log_file") 2>&1

# Trap errors to print a custom message indicating the line number
trap 'echo "Error occurred at line ${LINENO}." >&2' ERR

# Print in green for easy visibility in logs
print_green() {
    echo -e "\033[1;32m$1\033[0m"
}

print_green "Starting Ubuntu 24 setup script at $(date)"

# Capture the directory from which the script was started.
ORIGINAL_DIR="$(pwd)"
print_green "Original working directory: $ORIGINAL_DIR"

###############################################################################
# FUNCTION: install_firacode
# Description: Downloads the FiraCode zip from GitHub (via Nerd Fonts release), 
# extracts it, installs the TTF files if they’re not already installed, and updates 
# the font cache.
###############################################################################
install_firacode() {
    print_green "Checking if FiraCode fonts are installed..."
    if fc-list | grep -qi "FiraCode"; then
        print_green "FiraCode fonts already installed. Skipping."
        return 0
    fi

    print_green "Installing FiraCode fonts..."
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    
    # Use pushd/popd to change directory temporarily.
    pushd "$tmp_dir" > /dev/null

    print_green "Downloading FiraCode from $url"
    if ! wget "$url" -O FiraCode.zip; then
        print_green "Error: Failed to download FiraCode zip from $url"
        exit 1
    fi

    print_green "Extracting FiraCode zip..."
    if ! unzip -q FiraCode.zip; then
        print_green "Error: Failed to unzip FiraCode.zip"
        exit 1
    fi

    mkdir -p "$HOME/.local/share/fonts/FiraCode"
    if [ -d ttf ]; then
        cp ttf/*.ttf "$HOME/.local/share/fonts/FiraCode/"
    else
        if ls *.ttf 1> /dev/null 2>&1; then
            cp *.ttf "$HOME/.local/share/fonts/FiraCode/"
        else
            print_green "Warning: No TTF files found in the expected locations."
            exit 1
        fi
    fi

    print_green "Refreshing font cache..."
    if ! fc-cache -f -v "$HOME/.local/share/fonts/FiraCode"; then
        print_green "Error: Failed to update font cache."
        exit 1
    fi

    popd > /dev/null
    rm -rf "$tmp_dir"
    print_green "FiraCode fonts installed."
}

###############################################################################
# FUNCTION: install_oh_my_zsh
# Description: Installs oh-my-zsh using its official installer if not already installed.
###############################################################################
install_oh_my_zsh() {
    print_green "Checking if oh-my-zsh is installed..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_green "oh-my-zsh already installed. Skipping."
        return 0
    fi

    print_green "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
    print_green "oh-my-zsh installation completed."
}

###############################################################################
# FUNCTION: install_oh_my_zsh_plugins
# Description: Installs oh-my-zsh custom plugins:
#              - zsh-autosuggestions
#              - zsh-syntax-highlighting
###############################################################################
install_oh_my_zsh_plugins() {
    print_green "Installing oh-my-zsh custom plugins..."
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]; then
        print_green "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
    else
        print_green "zsh-autosuggestions already installed."
    fi

    if [ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]; then
        print_green "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
    else
        print_green "zsh-syntax-highlighting already installed."
    fi
}

###############################################################################
# FUNCTION: install_tilix
# Description: Installs Tilix terminal emulator if not already present.
###############################################################################
install_tilix() {
    print_green "Checking if Tilix is installed..."
    if command -v tilix >/dev/null 2>&1; then
        print_green "Tilix already installed. Skipping."
        return 0
    fi

    print_green "Installing Tilix..."
    sudo apt update
    sudo apt install -y tilix
    print_green "Tilix installed."
    print_green "Select Tilix as default terminal emulator:"
    sudo update-alternatives --config x-terminal-emulator
}

###############################################################################
# FUNCTION: setup_system_tools
# Description: Installs common development tools.
###############################################################################
setup_system_tools() {
    print_green "Installing system tools: build-essential, vim, cmake, gettext, unzip..."
    sudo apt install -y build-essential vim cmake gettext unzip
}

###############################################################################
# FUNCTION: setup_vim
# Description: Writes a basic Vim configuration to ~/.vimrc if it doesn't exist.
###############################################################################
setup_vim() {
    print_green "Checking if ~/.vimrc already exists..."
    if [ -f "$HOME/.vimrc" ]; then
        print_green "~/.vimrc already exists. Skipping vim configuration."
        return 0
    fi

    print_green "Setting up vim configuration..."
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
    print_green "Vim configuration written to ~/.vimrc"
}

###############################################################################
# FUNCTION: setup_neovim
# Description: Clones, builds, and installs Neovim if not already installed,
# and sets up the Neovim template.
###############################################################################
setup_neovim() {
    print_green "Checking if Neovim is installed..."
    if command -v nvim >/dev/null 2>&1; then
        print_green "Neovim already installed. Skipping building Neovim."
    else
        print_green "Installing Neovim (release-0.10 branch)..."
        git clone https://github.com/neovim/neovim.git -b release-0.10 ~/neovim-source
        pushd ~/neovim-source > /dev/null
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
        popd > /dev/null
    fi

    print_green "Checking if Neovim template is set up..."
    if [ -d "$HOME/.config/nvim" ]; then
        print_green "Neovim template already exists. Skipping cloning template."
    else
        print_green "Cloning Neovim template..."
        git clone https://github.com/jamesGadoury/nvim-template "$HOME/.config/nvim"
        pushd "$HOME/.config/nvim" > /dev/null
        chmod +x install_reqs.bash
        ./install_reqs.bash
        popd > /dev/null
    fi
    print_green "Neovim setup completed."
}

###############################################################################
# FUNCTION: setup_git
# Description: Configures Git with your user name and email if not already set.
###############################################################################
setup_git() {
    print_green "Checking git configuration..."
    current_email=$(git config --global user.email || print_green "")
    current_name=$(git config --global user.name || print_green "")
    if [[ "$current_email" == "gadouryjames@gmail.com" && "$current_name" == "James Gadoury" ]]; then
        print_green "Git already configured. Skipping."
    else
        print_green "Configuring git..."
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
    print_green "Checking for existing SSH keys..."
    if [ ! -d "$HOME/.ssh" ]; then
        print_green "No .ssh directory found. Creating one..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
    fi

    if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
        print_green "An SSH key already exists. Skipping ssh-keygen."
    else
        print_green "Generating a new SSH key using ed25519..."
        ssh-keygen -t ed25519 -C "gadouryjames@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
        print_green "SSH key generated. Your public key is:"
        cat "$HOME/.ssh/id_ed25519.pub"
    fi
}

###############################################################################
# FUNCTION: setup_miniconda
# Description: Installs Miniconda if not already present, initializes it for zsh,
# and creates the default conda environment for machine learning.
###############################################################################
setup_miniconda() {
    print_green "Checking if Miniconda is installed..."
    if [ -d "$HOME/miniconda3" ]; then
        print_green "Miniconda already installed. Skipping."
    else
        print_green "Installing Miniconda..."
        mkdir -p "$HOME/miniconda3"
        wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$HOME/miniconda3/miniconda.sh"
        bash "$HOME/miniconda3/miniconda.sh" -b -u -p "$HOME/miniconda3"
        rm -f "$HOME/miniconda3/miniconda.sh"
        "$HOME/miniconda3/bin/conda" init zsh
        print_green "Miniconda installed and initialized for zsh."
    fi

    print_green "Checking if the 'ml' conda environment exists..."
    if "$HOME/miniconda3/bin/conda" info --envs | grep -q "^ml\s"; then
        print_green "'ml' conda environment already exists. Skipping environment creation."
    else
        print_green "Setting up default 'ml' environment..."
        "$HOME/miniconda3/bin/conda" create -n ml -y
        "$HOME/miniconda3/bin/conda" install -n ml -y pytorch torchvision torchaudio pytorch-cuda=11.8 scikit-learn numpy scipy pandas matplotlib -c conda-forge -c pytorch -c nvidia
    fi
}

###############################################################################
# FUNCTION: setup_docker
# Description: Installs Docker Engine if not already present.
###############################################################################
setup_docker() {
    print_green "Checking if Docker Engine is installed..."
    if command -v docker >/dev/null 2>&1; then
        print_green "Docker already installed. Skipping."
        return 0
    fi

    print_green "Installing Docker Engine..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    print_green "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
         | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    print_green "Docker Engine installed."
}

###############################################################################
# FUNCTION: setup_libraries
# Description: Installs additional libraries (Eigen, PCL, OpenCV, CLI11). 
###############################################################################
setup_libraries() {
    print_green "Installing libraries: Eigen, PCL, OpenCV, CLI11..."
    sudo apt install -y libeigen3-dev libeigen3-doc
    sudo apt install -y libpcl-dev libpcl-doc pcl-tools
    sudo apt install -y libopencv-dev
    sudo apt install -y libcli11-dev
    sudo apt install -y btop
    print_green "Libraries installed."
}

###############################################################################
# FUNCTION: install_systemclipboard
# Description: Installs the xsel system clipboard utility if not already installed.
###############################################################################
install_systemclipboard() {
    print_green "Checking if xsel is installed..."
    if command -v xsel >/dev/null 2>&1; then
        print_green "xsel already installed. Skipping."
        return 0
    fi

    print_green "Installing system clipboard tool: xsel..."
    sudo apt install -y xsel
}

###############################################################################
# FUNCTION: install_zsh
# Description: Installs Zsh and required tools if not already installed.
###############################################################################
install_zsh() {
    print_green "Checking if zsh is installed..."
    if command -v zsh >/dev/null 2>&1; then
        print_green "zsh already installed. Skipping."
        return 0
    fi

    print_green "Installing zsh, curl, and git..."
    sudo apt install -y zsh curl git
}

###############################################################################
# FUNCTION: configure_custom_keybindings
# Description: Configures GNOME custom keybindings for:
#   - Super+f opens the file explorer (Nautilus) to the home directory.
#   - Super+t opens the default terminal (Tilix).
###############################################################################
configure_custom_keybindings() {
    print_green "Configuring custom keybindings..."
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

    print_green "Custom keybindings configured: <Super>f for file explorer and <Super>t for terminal."
}

###############################################################################
# FUNCTION: setup_nvidia_utilities
# Description: Installs nvtop and nvidia-container-runtime if an NVIDIA GPU is present.
###############################################################################
setup_nvidia_utilities() {
    print_green "Checking for NVIDIA GPU..."
    if lspci | grep -i nvidia > /dev/null; then
        print_green "NVIDIA GPU detected. Installing utilities..."

        sudo apt install -y nvtop

        # Check if nvidia-container-toolkit is already installed
        if dpkg -s nvidia-container-toolkit >/dev/null 2>&1; then
            print_green "nvidia-container-runtime is already installed. Skipping NVIDIA utilities setup."
        else
            # Set up the NVIDIA Container Toolkit repo (Ubuntu 24.04)
            curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
              && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
                sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

            sudo apt update
            sudo apt install -y nvidia-container-toolkit

            print_green "NVIDIA utilities installed. To use NVIDIA with Docker, set the default runtime:"
            print_green "  sudo mkdir -p /etc/docker"
            print_green "  echo '{ \"default-runtime\": \"nvidia\", \"runtimes\": { \"nvidia\": { \"path\": \"nvidia-container-runtime\", \"runtimeArgs\": [] } } }' | sudo tee /etc/docker/daemon.json"
            print_green "  sudo systemctl restart docker"
        fi
    else
        print_green "No NVIDIA GPU detected. Skipping NVIDIA utilities installation."
    fi
}

###############################################################################
# FUNCTION: setup_pydrake_venv
# Description: Creates a Python virtual environment in your home directory 
# for pydrake, and installs pydrake via pip along with some common dependencies.
###############################################################################
setup_pydrake_venv() {
    print_green "Setting up a Python virtual environment for pydrake..."
    VENV_DIR="$HOME/pydrake_venv"
    
    if [ -d "$VENV_DIR" ]; then
        print_green "Virtual environment already exists at $VENV_DIR, skipping creation."
    else
        print_green "Creating virtual environment at $VENV_DIR..."
        python3 -m venv "$VENV_DIR"
    fi
    
    print_green "Activating virtual environment and installing pydrake via pip..."
    source "$VENV_DIR/bin/activate"
    
    print_green "Upgrading pip..."
    pip install --upgrade pip

    print_green "Installing pydrake..."
    pip install pydrake

    print_green "Installing additional dependencies (numpy, scipy, matplotlib)..."
    pip install numpy scipy matplotlib cvxpy

    print_green "Virtual environment for pydrake is set up. To use it, run: source $VENV_DIR/bin/activate"
    
    deactivate
}

###############################################################################
# FUNCTION: install_rust
# Description: Installs the Rust programming language using rustup if it 
#              is not already installed.
###############################################################################
install_rust() {
    print_green "Checking if Rust is installed..."
    if command -v rustup >/dev/null 2>&1; then
        print_green "Rust is already installed. Skipping."
        return 0
    fi

    print_green "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    # Add the Cargo bin directory to PATH for the current session.
    export PATH="$HOME/.cargo/bin:$PATH"

    print_green "Rust installation complete."
}

update_shell_configs() {
    local BACKUP_DIR="$HOME/backups"

    # Create the backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"

    # Generate a timestamp in the format YYYYMMDD-HHMMSS
    local TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

    # Back up the current configuration files if they exist
    if [ -f "$HOME/.zshrc" ]; then
        print_green "Backing up $HOME/.zshrc to $BACKUP_DIR/.zshrc-$TIMESTAMP"
        cp -f "$HOME/.zshrc" "$BACKUP_DIR/.zshrc-$TIMESTAMP"
    fi

    if [ -f "$HOME/.bash_aliases" ]; then
        print_green "Backing up $HOME/.bash_aliases to $BACKUP_DIR/.bash_aliases-$TIMESTAMP"
        cp -f "$HOME/.bash_aliases" "$BACKUP_DIR/.bash_aliases-$TIMESTAMP"
    fi

    # Overwrite the live configuration files with the new ones
    cp -f "$ORIGINAL_DIR/.zshrc" "$HOME/.zshrc"
    cp -f "$ORIGINAL_DIR/.bash_aliases" "$HOME/.bash_aliases"
}


###############################################################################
# FUNCTION: main
# Description: Calls the above functions in order to perform the full setup.
###############################################################################
main() {
    print_green "Starting Ubuntu automated setup..."

    sudo apt update

    setup_system_tools

    install_zsh
    install_oh_my_zsh
    install_oh_my_zsh_plugins

    install_tilix

    install_firacode

    setup_vim

    setup_neovim

    setup_git

    setup_ssh_keys

    setup_miniconda

    setup_docker

    setup_libraries

    install_systemclipboard

    configure_custom_keybindings

    setup_nvidia_utilities

    setup_pydrake_venv

    install_rust

    update_shell_configs

    print_green "Ubuntu 24 setup complete at $(date)."
}

main

