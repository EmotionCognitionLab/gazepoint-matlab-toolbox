function ExecuteRecordGP3Data(session1_client, outputFileName, varargin)
%Starts a new Matlab session and runs RecordGP3Data function; Also pauses
%the main Matlab session to give the new session time to load up
%
%varargin are the user-defined GP3 data configuration options for session2
%client

SendMsgToGP3(session1_client,'');
fprintf(session1_client, '<SET ID="ENABLE_SEND_USER_DATA" STATE="1" />');
fprintf(session1_client, '<SET ID="ENABLE_SEND_DATA" STATE="1" />');
SendMsgToGP3(session1_client,'START_RECORDING')

if exist([pwd '/RecordGP3Data.m'],'file')
    % run this if the GP3 functions are in the same folder as the main
    % script
    eval(['!matlab -nosplash -nodesktop -r "RecordGP3Data(''' outputFileName ',' varargin ''')" &'])
else
    % run this if the GP3 functions are in a sub-folder of the main script
    eval(['!matlab -nosplash -nodesktop -r "addpath(genpath(pwd)); RecordGP3Data(''' outputFileName ',' varargin ''')" &'])
end

fprintf('\n Connecting with session 2 client. Please wait...\n\n')
pause(.05)

%% Wait until session2 client is ready
time_start=tic;
while  1
    %scan data from buffer and parse the xml format
    dataReceived = fscanf(session1_client);
    split = strsplit(dataReceived,'"');
    current_user_data = split{end-1};
    if strcmp(current_user_data,'CLIENT2_READY')
        fprintf('\nConnection Successful! Starting Experiment...\n\n')
        break
    end
    if toc(time_start) > 60
        error('Connection time out: could not connect to session 2 client;')
    end
     pause(.01);
end

%% Stop recording on this client
fprintf(session1_client, '<SET ID="ENABLE_SEND_DATA" STATE="0" />');

commandwindow; %returns window control to session 1's command window
