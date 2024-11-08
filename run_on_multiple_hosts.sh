#!/bin/bash

# Script to copy and execute a script on multiple hosts via SSH

# Usage: ./run_on_multiple_hosts.sh -u username -s script.sh [-h hosts.txt]

# Default values
HOSTS_FILE="hosts.txt"

# Function to display usage
usage() {
    echo "Usage: $0 -u username -s script.sh [-h hosts_file]"
    echo "  -u username       Username for SSH login"
    echo "  -s script.sh      Script to copy and execute"
    echo "  -h hosts_file     File containing host IPs (default: hosts.txt)"
    exit 1
}

# Parse command-line arguments
while getopts ":u:s:h:" opt; do
  case $opt in
    u)
      USER="$OPTARG"
      ;;
    s)
      SCRIPT="$OPTARG"
      ;;
    h)
      HOSTS_FILE="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      usage
      ;;
  esac
done

# Check if USER and SCRIPT are set
if [ -z "$USER" ] || [ -z "$SCRIPT" ]; then
    usage
fi

# Check if the script exists
if [ ! -f "$SCRIPT" ]; then
    echo "Error: $SCRIPT not found."
    exit 1
fi

# Check if the hosts file exists
if [ ! -f "$HOSTS_FILE" ]; then
    echo "Error: Hosts file $HOSTS_FILE not found."
    exit 1
fi

# Loop over each host
while read -r line; do
    # Skip empty lines and comments
    if [ -z "$line" ] || [[ "$line" =~ ^# ]]; then
        continue
    fi

    # Extract the host IP (assuming it's the first token in the line)
    host=$(echo "$line" | awk '{print $1}')
    echo "Processing $host..."

    # Copy the script
    scp "$SCRIPT" "$USER@$host:~/"
    if [ $? -ne 0 ]; then
        echo "Failed to copy script to $host"
        continue
    fi

    # Execute the script with pseudo-terminal allocation
    ssh -t "$USER@$host" "bash ~/$SCRIPT"
    if [ $? -ne 0 ]; then
        echo "Failed to execute script on $host"
        continue
    fi

    echo "Completed $host."
done < "$HOSTS_FILE"