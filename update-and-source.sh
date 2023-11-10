#!/bin/bash

# Define variables
repo_url="git@github.com:maciek-pioro/commands.git"
scripts_dir="$HOME/mp-scripts"
functions_file="$scripts_dir/functions.sh"

# Display warning and prompt for user confirmation
read -t 1 -p "Updating script. Press Ctrl-C within 1 second to skip... " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Cc]$ ]]; then
    echo "Update skipped by user."
    exit 0
fi

# Clone or pull the latest version of the git repo
if [ -d "$scripts_dir" ]; then
    echo "Updating existing repo..."
    cd "$scripts_dir" || exit 1
    git pull
else
    echo "Cloning the repo for the first time..."
    git clone "$repo_url" "$scripts_dir"
fi

# Check if the clone or pull was successful
if [ $? -ne 0 ]; then
    echo "Failed to update the script. Exiting."
    exit 1
fi

# Source the functions file
source "$functions_file"

echo "Script update successful."
