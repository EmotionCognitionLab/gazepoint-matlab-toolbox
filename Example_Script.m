%% Generate path to GP3 subfolders
[mainDir,~,~] = fileparts(mfilename('fullpath'));
addpath(genpath(mainDir));

%% Set-up Matlab to GP3 session1 socket
session1_client = ConnectToGP3;

%% Spawn a second Matlab session2 that records GP3 data to output file
outputFileName = 'example_output.txt';
ExecuteRecordGP3Data(session1_client,outputFileName);

%% Experiment (stimuli presentation) goes here
for trial_num=1:5
    % Start of new trial here
    SendMsgToGP3(session1_client,['trial_start' num2str(trial_num)]); %send msg trigger for start of the trial
    pause(2);
    % Present a stimuli here
    SendMsgToGP3(session1_client,['stimuli' num2str(trial_num)]); %send msg trigger for onset of new stimuli
    pause(2);  
end

%% Stop collecting data in client2
fprintf('Stop recording\n')
SendMsgToGP3(session1_client,'STOP_EYETRACKER');

%% Clean-up socket
CleanUpSocket(session1_client);
fclose all;
