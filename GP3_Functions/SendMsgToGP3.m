function SendMsgToGP3(session1_client, message)
%Sets the USER_DATA tag of the GP3 data stream to the user-defined message.
%This serves as synchronization triggers between the experiment and the
%eye-tracker data stream.

command = ['<SET ID="USER_DATA" VALUE="' message '" />'];
fprintf(session1_client, command);

end

