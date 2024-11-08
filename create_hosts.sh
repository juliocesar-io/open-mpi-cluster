#!/bin/bash

# Script to generate a hosts.txt file with a list of IP addresses and slots

# Usage: ./generate_hosts.sh <start_ip> <number_of_hosts>

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <start_ip> <number_of_hosts>"
    exit 1
fi

START_IP=$1
NUM_HOSTS=$2

# Validate NUM_HOSTS is a positive integer
if ! [[ "$NUM_HOSTS" =~ ^[0-9]+$ ]] ; then
   echo "Error: number_of_hosts must be a positive integer."
   exit 1
fi

# Split the IP address into its components
IFS='.' read -r -a IP_PARTS <<< "$START_IP"

if [ "${#IP_PARTS[@]}" -ne 4 ]; then
    echo "Error: Invalid IP address format."
    exit 1
fi

# Extract the last octet and validate it
LAST_OCTET="${IP_PARTS[3]}"

if ! [[ "$LAST_OCTET" =~ ^[0-9]+$ ]] || [ "$LAST_OCTET" -lt 0 ] || [ "$LAST_OCTET" -gt 255 ]; then
    echo "Error: Invalid last octet in IP address."
    exit 1
fi

# Generate the hosts.txt file in the user's home directory
> "$HOME/hosts.txt"

for (( i=0; i<NUM_HOSTS; i++ ))
do
    CURRENT_OCTET=$((LAST_OCTET + i))
    if [ "$CURRENT_OCTET" -gt 255 ]; then
        echo "Error: IP address octet exceeds 255."
        exit 1
    fi
    IP="${IP_PARTS[0]}.${IP_PARTS[1]}.${IP_PARTS[2]}.$CURRENT_OCTET"
    echo "$IP slots=1" >> "$HOME/hosts.txt"
done

echo "hosts.txt generated successfully in the user's home directory."