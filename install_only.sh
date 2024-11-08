#!/bin/bash

# This script installs Open MPI.

set -e

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
echo "Please ensure that $PREFIX/bin is in your PATH to use Open MPI commands."