
# Open MPI Cluster Setup


## Requirements


Nodes are connected to the same network with SSH sharing enabled. 

- Installed Open MPI on each node.
- Set up passwordless SSH access.
- Configured firewall settings for MPI communication.
- Written and compiled a simple MPI program. (Same code and path for each node)
- Executed the MPI program across all nodes.


## Install Open MPI and create user in the main node


> [!TIP]
> Make sure to change the password in the `install.sh` script to a strong one.

Run the `install.sh` script to install Open MPI on each node. This script will create a user `mpi` with password `cluster123` and add it to the sudoers group.

It will also install Open MPI to `/usr/local` and add it to the PATH.

Make the script executable:

```bash
chmod +x install.sh
```

Run the script in the master node:

```bash
./install.sh
```

Use the `mpi` user.

```bash
su mpi
```

Check if Open MPI is installed:

```bash
mpirun --version
```

## Create hosts.txt file in the main node

> [!TIP]
> Make sure to change the start IP in the `create_hosts.sh` script to a valid IP address for your network.

Log in as the `mpi` user:

```bash
su mpi
```

Run the `create_hosts.sh` script to create the `hosts.txt` file in the user's home directory.

This script will create a list of IP addresses and slots in the `hosts.txt` file.

```bash
./scripts/create_hosts.sh <start_ip> <number_of_hosts>
```


## Install Open MPI and create user in each node

Now repeat the steps in each node. Use the utility script `run_on_multiple_hosts.sh` to copy and execute a script on multiple hosts via SSH.

Make the script executable:

```bash
chmod +x run_on_multiple_hosts.sh
```

Run the script in the master node, make sure the `hosts.txt` is in the same directory as the script or provide the full path to the file using the `-h` option:

```bash
./run_on_multiple_hosts.sh -u mpi -s install.sh
```

## Compile the MPI program on each node


Compile the MPI program on the main node:

Make the script executable:

```bash
chmod +x compile.sh
```

Run the script in the main node:

```bash
./compile.sh 
```

This script will compile the `mpi_test.c` file and place the `mpi_test` executable in the user's home directory.

Now repeat the steps in each node. Use the utility script `run_on_multiple_hosts.sh` to copy and execute a script on multiple hosts via SSH.


```bash
./run_on_multiple_hosts.sh -u mpi -s compile.sh
```


## Run the MPI program across all nodes


With the `hosts.txt` file in the main node, run the MPI program in the main node:

All nodes must have the `mpi_test` executable in their home directory in the `mpi` user.

```bash
mpirun -np <number_of_nodes> --hostfile hosts.txt ./mpi_test
```


