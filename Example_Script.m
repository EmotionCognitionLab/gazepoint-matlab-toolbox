%% Generate path to GP3 subfolders
[mainDir,~,~] = fileparts(mfilename('fullpath'));
addpath(genpath(mainDir));

%% Set-up Matlab to GP3 socket
session1_client = ConnectToGP3;

%% Start recording data into a output file
outputFileName = 'example_output.txt';
ExecuteRecordGP3Data(session1_client,outputFileName);

%% Experiment goes here (as well as the USER_DATA triggers)
for trial_num=1:5
    message = ['trial' num2str(trial_num)];
    fprintf([message '\n'])
    SendMsgToGP3(session1_client,message);
    pause(2);
end

%% Stop collecting data in client2
fprintf('Stop recording\n')
SendMsgToGP3(session1_client,'STOP_EYETRACKER');

%% Clean-up socket
CleanUpSocket(session1_client);
fclose all;