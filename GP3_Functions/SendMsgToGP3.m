function SendMsgToGP3(session1_client, message)
%Sets the USER_DATA tag of the GP3 data stream to the user-defined message.
%This serves as synchronization triggers between the experiment and the
%GP3 data stream.
%
%Author: Ringo Huang (ringohua@usc.edu)
%Created: 8/8/2017
%Last Update: 8/20/2017

command = ['<SET ID="USER_DATA" VALUE="' message '" />'];
fprintf(session1_client, command);
