function session1_client = ConnectToGP3
%Creates Matlab client to GP3 server TCP socket in the main Matlab session

%% set-up and configure socket
session1_client = tcpip('127.0.0.1', 4242);
session1_client.InputBufferSize = 4096;
fopen(session1_client);
session1_client.Terminator = 'CR/LF';