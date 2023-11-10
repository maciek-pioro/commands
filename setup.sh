# Define variables
scripts_dir="$HOME/mp-scripts"
backup_dir="$HOME/mp-scripts-backup"
bashrc_file="$HOME/.bashrc"
zshrc_file="$HOME/.zshrc"

# Check if the scripts directory exists
if [ ! -d "$scripts_dir" ]; then
    echo "Error: mp-scripts directory does not exist. Please run the update script first."
    exit 1
fi

# Create a backup directory if it doesn't exist
if [ ! -d "$backup_dir" ]; then
    mkdir "$backup_dir"
fi

# Function to backup a file
backup_file() {
    local file=$1
    local backup_file="$backup_dir/$(basename $file)_backup_$(date +%Y%m%d%H%M%S)"
    cp "$file" "$backup_file"
    echo "Backup created: $backup_file"
}

# Function to add sourcing to the shell configuration file
add_sourcing() {
    local shell_file=$1
    local source_line="source $scripts_dir/functions.sh"

    # Backup the original file
    backup_file "$shell_file"

    # Check if the source line already exists in the file
    if ! grep -qF "$source_line" "$shell_file"; then
        # Add the source line to the file
        echo -e "\n# Sourcing mp-scripts functions\n$source_line" >> "$shell_file"
        echo "Sourcing added to $shell_file"
    else
        echo "Sourcing already present in $shell_file"
    fi
}

# Detect the user's shell and add sourcing accordingly
if [ -n "$BASH_VERSION" ]; then
    
    add_sourcing "$bashrc_file"
elif [ -n "$ZSH_VERSION" ]; then
    add_sourcing "$zshrc_file"
else
    echo "Unsupported shell. Please add the following line to your shell configuration manually:"
    echo "source $scripts_dir/functions.sh"
fi

echo "Setup completed successfully."
