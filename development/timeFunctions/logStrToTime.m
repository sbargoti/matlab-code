function [ dt, us, utcoffset ] = logStrToTime( time_str )
% LOGSTRTOTIME 
% Convert input in string format that the logs are saved in to a datetime
% format for matlab. 

% Get the micro-seconds time
us = str2num(time_str(17:end));

% Convert string to relevant input for datetime
time_str = strcat(time_str(1:4),'-',time_str(5:6),'-',time_str(7:11),':',time_str(12:13),':',time_str(14:15),'Z');

% Convert time_str to datetime
dt = datetime(time_str,'InputFormat','yyyy-MM-dd''T''HH:mm:ss Z','TimeZone','local');

% Get the time offset
utcoffset = hours(tzoffset(dt));

end

