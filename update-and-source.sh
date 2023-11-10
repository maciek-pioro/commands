# Define variables
repo_url="git@github.com:maciek-pioro/commands.git"
scripts_dir="$HOME/mp-scripts"
functions_file="$scripts_dir/functions.sh"
SKIP=0


handle_interrupt() {
    echo "Interrupted."
    SKIP=1
    trap - SIGINT
}

trap handle_interrupt SIGINT

# Display warning and prompt for user confirmation
TIMEOUT=2
echo "Updating script. Press Ctrl-C within $TIMEOUT second to skip... "
sleep $TIMEOUT
echo

trap - SIGINT

if [ $SKIP -eq 0 ]; then
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
else 
    echo "Skipping update and sourcing"
fi
