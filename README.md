# gazepoint-matlab-toolbox
This toolbox allows Matlab users to interface with Gazepoint eyetrackers.

The simplest way to implement this toolbox in your Matlab/Psychtoolbox experiments is to use Example_Script.m as a template. 

### Quickstart Guide
1. Install the Gazepoint applications from this link (https://www.gazept.com/downloads/). Then, download the gazepoint-matlab-toolbox and save the Matlab functions in the GP3_Functions the directory or a sub-directory of your main experiment script.
2. At the beginning of your main experiment script, include the following lines of code to set up connections with the GP3 eye-tracker. The ConnectToGP3 function creates a socket connection with the GP3 server in the main Matlab session (session1). This session1 socket is used to send synchronization triggers from the experiment script to the eye-tracking data stream. The ExecuteRecordGP3Data function spawns a new Matlab session (session2) and creates another socket. The session2 TCPIP socket reads the eye-tracking data from its input buffer and stores the data in a text file.
```
%% Set-up Matlab to GP3 session1 socket
session1_client = ConnectToGP3;

%% Spawn a second Matlab session2 that records GP3 data to output file
outputFileName = 'example_output.txt';
ExecuteRecordGP3Data(session1_client,outputFileName);
```
3. In the stimuli presentation body of your main script, it's important to embed synchronization messages in your eye-tracking data stream. Mark any event of interest by including the SendMsgToGP3 function in your script. For example, you may want to send a message trigger at the start of a new trial, at the onset and/or offset of a stimuli, or after a participant button response.
```
%% Experiment (stimuli presentation) goes here
for trial_num=1:5
    % Start of new trial here
    SendMsgToGP3(session1_client,['trial_start' num2str(trial_num)]); %send msg trigger for start of the trial
    pause(2);
    % Present a stimuli here
    SendMsgToGP3(session1_client,['stimuli' num2str(trial_num)]); %send msg trigger for onset of new stimuli
    pause(2);  
end
```
4. After the behavioral experiment completes, tell the session2 socket to stop collecting data.
```
%% Stop collecting data in session2 socket
SendMsgToGP3(session1_client,'STOP_EYETRACKER');
```
5. Finally, close the session1 socket.
```
CleanUpSocket(session1_client);
```
