% Testing the sun position code
clc;

% Set example time stamp from data
time_str = '20131203T052418.141278';
time_str = '20131203T042418.141278';

% Convert to date time
[datetime_str, ~, utc_offset] = logStrToTime(time_str);

% Split into different components
[ct.year, ct.month, ct.day, ct.hour, ct.min, ct.sec] = datevec(datetime_str);

% Add utc offset
ct.UTC = utc_offset;

% Set latitude and longitude
lat = 33.9;
long = 151.2;
location.latitude = lat;
location.longitude = long;
location.altitude = 0;

% Evaluate sun position
s_pos = sun_position(ct, location)

%   location: a structure that specify the location of the observer
%       location.latitude: latitude (in degrees, north of equator is
%       positive)
%       location.longitude: longitude (in degrees, positive for east of
%       Greenwich)
%       location.altitude: a

%       time.year: year. Valid for [-2000, 6000]
%       time.month: month [1-12]
%       time.day: calendar day [1-31]
%       time.hour: local hour [0-23]
%       time.min: minute [0-59]
%       time.sec: second [0-59]
%       time.UTC: offset hour from UTC. Loc;