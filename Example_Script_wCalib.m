%% Generate path to GP3 subfolders
[mainDir,~,~] = fileparts(mfilename('fullpath'));
addpath(genpath(mainDir));

%% Set-up Matlab to GP3 session1 socket
session1_client = ConnectToGP3;

%% Calibration (Important that this goes before ExecuteRecordGP3Data)
calib = 1;
while calib == 1
    StartCalibration(session1_client);
    fprintf(session1_client, '<GET ID="CALIBRATE_RESULT_SUMMARY" />');
    while  session1_client.BytesAvailable > 0
        dataReceived = fscanf(session1_client);
        split = strsplit(dataReceived,'"');
        if strcmp(split{2},'CALIBRATE_RESULT_SUMMARY')
            if strcmp(split{6},'5')
                calib = 0;
            end
        end
    end
end


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
