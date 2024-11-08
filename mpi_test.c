#include <mpi.h>
#include <stdio.h>
#include <stdlib.h> 
#include <unistd.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>

int main(int argc, char* argv[]) {
    int rank, size, data;
    MPI_Status status;
    char hostname[256];
    char ip_address[INET_ADDRSTRLEN];
    struct hostent *host_entry;
    struct in_addr **addr_list;

    MPI_Init(&argc, &argv);               // Initialize MPI environment
    MPI_Comm_rank(MPI_COMM_WORLD, &rank); // Get rank
    MPI_Comm_size(MPI_COMM_WORLD, &size); // Get number of processes

    // Get the hostname
    gethostname(hostname, sizeof(hostname));

    // Get the host entry
    host_entry = gethostbyname(hostname);
    if (host_entry == NULL) {
        perror("gethostbyname");
        exit(1);
    }

    // Convert the address into an IP address string
    addr_list = (struct in_addr **)host_entry->h_addr_list;
    strcpy(ip_address, inet_ntoa(*addr_list[0]));

    printf("Process %d started on IP %s\n", rank, ip_address);

    if (rank == 0) {
        data = 100; // Sample data
        printf("Process %d sending data %d to process 1\n", rank, data);
        MPI_Send(&data, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
    } else if (rank == 1) {
        printf("Process %d waiting to receive data from process 0\n", rank);
        MPI_Recv(&data, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
        printf("Process %d received data %d from process 0\n", rank, data);
    }

    MPI_Finalize(); // Finalize MPI environment
    return 0;
}