# -----------------------------------------------------------------------------
# Directory and File Management Aliases
# -----------------------------------------------------------------------------
alias ll='ls -alF'              # Long listing format including hidden files
alias la='ls -A'                # List all files including hidden, but not '.' or '..'
alias l='ls -CF'                # Display files in columns
alias ..='cd ..'                # Go up one directory

# -----------------------------------------------------------------------------
# Git Shortcuts
# -----------------------------------------------------------------------------
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gb='git branch'

# -----------------------------------------------------------------------------
# Networking and System Information
# -----------------------------------------------------------------------------
alias ips='ifconfig | grep "inet "'  # List IP addresses (adjust if using Linux vs. macOS)
alias ping='ping -c 5'               # Ping with count of 5
alias myip='curl -s ifconfig.me'     # Get external IP address

# -----------------------------------------------------------------------------
# Disk and Process Utilities
# -----------------------------------------------------------------------------
alias df='df -h'                   # Disk free in human-readable format

du() {
  # run the real du with any args, then sort its output
  command du -h --max-depth=1 "$@" | sort -hr
}

alias topmem='ps aux --sort=-%mem | head -n 10'  # Top 10 memory-consuming processes
alias psg='ps aux | grep -v grep | grep -i'      # Search processes by keyword

# -----------------------------------------------------------------------------
# Data Analysis and Text Utilities
# -----------------------------------------------------------------------------
# Function: epoch_to_est
# Converts a Unix epoch timestamp into Eastern Time (EST/EDT depending on the date)
epoch_to_est() {
    if [ -z "$1" ]; then
        echo "Usage: epoch_to_est <epoch_seconds>"
        return 1
    fi
    TZ="America/New_York" date -d @"$1"
}

# Function: count_unique
# Counts unique words in a file, sorting them by frequency.
count_unique() {
    if [ -z "$1" ]; then
        echo "Usage: count_unique <file>"
        return 1
    fi
    # Break the file into words, sort and count frequency
    tr -cs '[:alnum:]' '[\n*]' < "$1" | sort | uniq -c | sort -rn
}

# Alias: count_lines
# Quickly count the number of lines in a file.
alias count_lines='awk '\''{count++} END {print count}'\'''

# -----------------------------------------------------------------------------
# File Searching Aliases
# -----------------------------------------------------------------------------
alias grep='grep --color=auto'     # Grep with color highlighting
alias findstr='grep -Rin'          # Recursively search for a string in files

# -----------------------------------------------------------------------------
# Miscellaneous
# -----------------------------------------------------------------------------
alias recent='ls -lt | head'       # List most recently modified files
alias cls='clear'                  # Clear terminal screen
alias rs="tput reset"
alias h='history'                  # Display command history

# Docker Shortcuts (if using Docker)
alias dps='docker ps'
alias di='docker images'
alias dcleanup='docker system prune -a'  # Remove unused Docker data

mib_to_bytes() {
    # Check that exactly one argument is provided.
    if [ "$#" -ne 1 ]; then
        echo "Usage: output_mib_size_in_bytes <number of mib>"
        return 1
    fi
    
    local num_mib=$1
    local mib_size=$(( 1 << 20 ))
    echo "$(($num_mib * $mib_size))"
}

gib_to_bytes() {
    # Check that exactly one argument is provided.
    if [ "$#" -ne 1 ]; then
        echo "Usage: output_gib_size_in_bytes <number of gib>"
        return 1
    fi
    
    local num_gib=$1
    local gib_size=$(( 1 << 30 ))
    echo "$(($num_gib * $gib_size))"
}

random_string() {
    # Check that exactly one argument is provided.
    if [ "$#" -ne 1 ]; then
        echo "Usage: generate_random_string <num_chars>"
        return 1
    fi

    local num_chars="$1"

    # Read more bytes than needed to ensure enough alphanumeric characters are available.
    # The generated string is output directly to stdout.
    head -c $((num_chars * 8)) /dev/urandom | tr -dc 'A-Za-z0-9' | head -c "$num_chars"
}


random_ints() {
    # Example usage:
    # generate_random_numbers 50 100 5

    # Check if exactly three parameters are provided
    if [ "$#" -ne 3 ]; then
        echo "Usage: generate_random_numbers <min> <max> <count>"
        return 1
    fi

    local min=$1
    local max=$2
    local count=$3

    # Ensure min is not greater than max
    if [ "$min" -gt "$max" ]; then
        echo "Error: min ($min) cannot be greater than max ($max)."
        return 1
    fi

    # Calculate the range
    local range=$(( max - min + 1 ))

    # Generate the random numbers and print them on the same line
    for (( i = 0; i < count; i++ )); do
        local random_number=$(( RANDOM % range + min ))
        printf "%s " "$random_number"
    done
    # End with a newline
    echo
}

random_floats() {
    if [ "$#" -ne 3 ]; then
        echo "Usage: generate_random_floats <min> <max> <count>"
        return 1
    fi

    local min="$1"
    local max="$2"
    local count="$3"

    # Validate that min is not greater than max using awk
    if ! awk -v m="$min" -v M="$max" 'BEGIN { exit (m > M) }'; then
        echo "Error: min ($min) cannot be greater than max ($max)."
        return 1
    fi

    local result=""
    for (( i = 0; i < count; i++ )); do
        local r=$RANDOM
        # Calculate a random float between min and max.
        # The awk command uses printf without appending a newline.
        local random_float=$(awk -v min="$min" -v max="$max" -v r="$r" 'BEGIN { printf "%.5f", min + (max - min) * r/32767 }')
        result+="${random_float} "
    done

    # Print all numbers on one line, space-delimited
    echo "$result"
}

alias rsync="rsync -avP --info=progress2 $1 $2"

alias ealias="nvim ~/.bash_aliases"
alias evimrc="nvim ~/.vimrc"
alias ezshrc="nvim ~/.zshrc"
alias ra="source ~/.bash_aliases"
alias szshrc="source ~/.zshrc"
alias p="python3"
alias h="history"
alias get_removed_packages="awk '!/^Start|^Commandl|^End|^Upgrade:|^Error:/ { gsub( /\([^()]*\)/ ,"" );gsub(/ ,/," ");sub(/^Install:/,""); print}' /var/log/apt/history.log"
alias rs="tput reset"
alias nv="nvim"

alias ml_env="source ~/ml-venv/bin/activate"
alias drake_env="source ~/drake-venv/bin/activate"

git_remote_to_ssh() {
    REMOTE_URL=$(git remote get-url origin); \
    if [[ $REMOTE_URL == https://github.com/* ]]; then \
    NEW_URL=$(echo $REMOTE_URL | sed "s|https://github.com/|git@github.com:|"); \
    git remote set-url origin "$NEW_URL"; \
    echo "Remote URL changed to SSH: $NEW_URL"; \
    else \
    echo "Remote URL is already using SSH or not a GitHub HTTPS URL."; \
    fi
}

