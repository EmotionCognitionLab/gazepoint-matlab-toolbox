function StartCalibration(session1_client, varargin)
%Runs the OpenGaze default calibration sequence for an optionally user-defined
%duration
%
%Author: Ringo Huang (ringohua@usc.edu)
%Created: 8/8/2017
%Last Update: 8/20/2017


narginchk(1,2);

if numel(varargin)==0
    delay = 10;
elseif numel(varargin)==1
    delay = varargin{1};
end

fprintf(session1_client, '<SET ID="CALIBRATE_RESET"/>');
fprintf(session1_client, '<SET ID="CALIBRATE_SHOW" STATE="1" />');
fprintf(session1_client, '<SET ID="CALIBRATE_START" STATE="1" />');
pause(delay);
fprintf(session1_client,'<SET ID="CALIBRATE_START" STATE="0" />');
fprintf(session1_client,'<SET ID="CALIBRATE_SHOW" STATE="0" />');

