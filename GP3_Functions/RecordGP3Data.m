function RecordGP3Data(outputFileName, varargin)
%Creates a client that reads GP3 data from its buffer and writes it to an
%output text file
%
%The first argument is the outputFileName
%If there is only one input argument, the default is to configure the data
%stream to send Left Pupil, Right Pupil, and Blink data.
%User may also specify the specific data types that they want to receive.
%
%Author: Ringo Huang (ringohua@usc.edu)
%Created: 8/8/2017
%Last Update: 8/20/2017

%% Set-up new file and socket
fileID = fopen(outputFileName,'w');

% set up address and port, and configure socket properties
session2_client = tcpip('127.0.0.1', 4242);
session2_client.InputBufferSize = 100000;
fopen(session2_client);
session2_client.Terminator = 'CR/LF';

%% Configure data stream
fprintf(session2_client, '<SET ID="ENABLE_SEND_TIME" STATE="1" />');
fprintf(session2_client, '<SET ID="ENABLE_SEND_COUNTER" STATE="1" />');
fprintf(session2_client, '<SET ID="ENABLE_SEND_USER_DATA" STATE="1" />');

if isempty(varargin) %default
    fprintf(session2_client, '<SET ID="ENABLE_SEND_PUPIL_LEFT" STATE="1" />');
    fprintf(session2_client, '<SET ID="ENABLE_SEND_PUPIL_RIGHT" STATE="1" />');
    fprintf(session2_client, '<SET ID="ENABLE_SEND_EYE_LEFT" STATE="1" />');
    fprintf(session2_client, '<SET ID="ENABLE_SEND_EYE_RIGHT" STATE="1" />');
    fprintf(session2_client, '<SET ID="ENABLE_SEND_BLINK" STATE="1" />');
elseif ~isempty(varargin)
    for i=1:length(varargin)
        fprintf(session2_client, ['<SET ID="' varargin{i} '" STATE="1" />']);
    end
end

% start data server sending data
fprintf(session2_client, '<SET ID="ENABLE_SEND_DATA" STATE="1" />');

%% Wait for START_RECORDING response from session1 client
time_start=tic;
fprintf('Connecting with session 1 client. Please wait...\n\n')
while  1
    %% Scan data from buffer and parse the xml format
    dataReceived = fscanf(session2_client);
    split = strsplit(dataReceived,'"');
    current_user_data = split{end-1};
    if strcmp(current_user_data,'START_RECORDING')
        previous_user_data = current_user_data;
        fprintf('\nConnection Successful! Start recording...\n\n')
        break
    end
    if toc(time_start) > 60
        error('Connection time out: could not connect to session 1 client;')
    end
    pause(.01);
end

%% Send message to let Matlab session1 know that session2 is ready
SendMsgToGP3(session2_client,'CLIENT2_READY');
pause(0.05)

%% Create header for output file
header = {};
for j=1:2:length(split)-2
    if j==1
        split{j} = split{j}(6:end); % remove the '<REC ' from the first header
    end
    header = [header, split{j}(1:end-1)];
end
fprintf(fileID,['DATATYPE\t' repmat('%s\t',1,length(header)) '\n'],header{:});

%% Read and parse data from the buffer
msg_count = 0;
while  session2_client.BytesAvailable > 0
        %% Scan data from buffer and parse the xml format
        dataReceived = fscanf(session2_client);
        split = strsplit(dataReceived,'"');
        current_user_data = split{end-1};
        
        if regexp(split{1},'<REC','once')        
            %% Extracts the values from the xml file
            value = {};
            for j=2:2:length(split)
                value = [value, split{j}];
            end
            
            %% Embeds message trigger in the data
            if ~strcmp(current_user_data,previous_user_data)
                % if the user_data tag differs from the previous sample, write
                % the user_data to the output data file as a trigger;
                % value{2} is Timestamp
                msg_count = msg_count + 1;
                previous_user_data = split{end-1};
                fprintf([split{end-1} '\n'])
                msg_time = str2double(value{2}) - .008;      %NOTE: the precise instance when the msg was sent is inaccurate within +/-8ms
                fprintf(fileID,'MSG\t%s\t%s\t%s\n',num2str(msg_count),num2str(msg_time),previous_user_data);
            end
            
            %% Stops reading data from the buffer
            if strcmp(current_user_data,'STOP_EYETRACKER')
                % the main experiment script sets the user_data tag as
                % "STOP_EYETRACKER" when it finishes data collection. When the
                % session2_client comes upon this user_tag, break the while
                % loop to stop reading data.
                fprintf(session2_client, '<SET ID="ENABLE_SEND_DATA" STATE="0" />');
                fprintf('Stopped data stream. Please wait for data to finish recording...\n')
                break
            end
            
            fprintf(fileID,['SMP\t' repmat('%s\t',1,length(value)) '\n'],value{:});
        end
        
        WaitForData(session2_client,10)        %Waits up to 10 seconds for input buffer to receive data
        pause(0.01);                           
end

%% Clean up
CleanUpSocket(session2_client);
fclose(fileID);
fprintf('Finished recording data. You can now close this Matlab session.\n')

function WaitForData(varargin)
%If client_socket.bytesavailable == 0, wait for a few seconds for buffer to 
%fill up; if no data is received after a time limit (default = 10s), 
%then client is closed

client = varargin{1};

if length(varargin)==1
    time_limit=10;              %default is 10seconds
elseif length(varargin)==2
    time_limit=varargin{2};
else
    error('Improper number of input arguments for WaitForData')
end

start_time = tic;
while get(client, 'BytesAvailable') == 0 && toc(start_time)<time_limit
end

if toc(start_time)>=10
    warning('Client stopped receiving data before STOP_EYETRACKER trigger was sent');
end