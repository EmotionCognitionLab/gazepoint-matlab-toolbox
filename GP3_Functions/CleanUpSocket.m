function CleanUpSocket(client_socket)
%Closes sockets

fclose(client_socket);
delete(client_socket);
clear client_socket