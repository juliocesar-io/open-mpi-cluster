#!/bin/bash

# Script to compile an existing C file using mpicc and place the files in the user's home directory

# Check if mpi_test.c exists in the current directory
if [ ! -f "mpi_test.c" ]; then
    echo "Error: mpi_test.c not found in the current directory."
    exit 1
fi

# Compile the C file using mpicc
echo "Compiling mpi_test.c..."
mpicc -o mpi_test mpi_test.c

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

# Copy the C file and executable to the user's home directory
echo "Copying files to your home directory..."
cp "mpi_test.c" "mpi_test" "$HOME"

echo "Files have been copied to $HOME:"
echo " - $HOME/mpi_test.c"
echo " - $HOME/mpi_test"

echo "Done."