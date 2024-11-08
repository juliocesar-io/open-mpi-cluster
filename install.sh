#!/bin/bash

# This script creates a user 'mpi', adds it to the sudoers group, and sets a default password.
# It also installs Open MPI and ensures the commands are available in the user's shell.

# Variables
USERNAME="mpi"
PASSWORD="cluster123"  # Replace with the desired default password

set -e

# Create the user with a home directory and default shell
sudo useradd -m -s /bin/bash "$USERNAME"

# Set the user's password
echo "${USERNAME}:${PASSWORD}" | sudo chpasswd

# Add the user to the sudo group
sudo usermod -aG sudo "$USERNAME"

echo "User '$USERNAME' has been created and added to the sudo group."

# Install Open MPI

# Variables
URL="https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.5.tar.gz"
TARFILE="openmpi-5.0.5.tar.gz"
DIR="openmpi-5.0.5"
PREFIX="/usr/local"
NUM_JOBS=$(nproc)

# Function to print usage
usage() {
    echo "Usage: $0 [-p prefix] [-j jobs]"
    echo "  -p prefix    Installation prefix (default: /usr/local)"
    echo "  -j jobs      Number of make jobs (default: number of processors)"
    exit 1
}

# Parse command line options
while getopts ":p:j:" opt; do
  case $opt in
    p)
      PREFIX="$OPTARG"
      ;;
    j)
      NUM_JOBS="$OPTARG"
      ;;
    \?)
      echo "Invalid option -$OPTARG"
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      usage
      ;;
  esac
done

echo "Downloading Open MPI from $URL..."
if command -v wget >/dev/null 2>&1; then
    wget $URL
elif command -v curl >/dev/null 2>&1; then
    curl -O $URL
else
    echo "Error: Neither wget nor curl is installed."
    exit 1
fi

echo "Extracting $TARFILE..."
tar -xzf $TARFILE

cd "$DIR"

echo "Configuring with prefix=$PREFIX..."
./configure --prefix="$PREFIX"

echo "Building with $NUM_JOBS jobs..."
make -j"$NUM_JOBS"

echo "Installing to $PREFIX..."
if [ "$EUID" -ne 0 ] && [ "$PREFIX" == "/usr/local" ]; then
    echo "You may be prompted for your password to install to $PREFIX"
    sudo make install
else
    make install
fi

echo "Updating shared library cache..."
if [ "$EUID" -ne 0 ]; then
    sudo ldconfig
else
    ldconfig
fi

cd ..
echo "Cleaning up..."
rm -rf "$TARFILE" "$DIR"

echo "Open MPI installed successfully to $PREFIX."

# Ensure Open MPI commands are available in the user's shell
echo "Updating $USERNAME's .bashrc to include Open MPI in PATH..."
echo "export PATH=\"$PREFIX/bin:\$PATH\"" | sudo tee -a "/home/$USERNAME/.bashrc" > /dev/null

echo "Setup complete. Open MPI commands are now available for user '$USERNAME'."