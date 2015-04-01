% ISO2SECONDS Convert format of time from iso string to seconds since epoch
%
%   time_as_seconds_since_epoch = ISO2SECONDS( time_as_iso_string ) converts 
%   between these two formats
%
%   Example
%   -------
%   seconds2iso(1399970753.498385)
%   seconds2iso(1.399970753498385e+009)
%
%   See also: seconds2iso
%
%   author Suchet Bargoti
function [ seconds ] = iso2seconds( iso )
[~, secondsStr] = dos(sprintf('echo %s| csv-time --to-seconds',iso));
seconds = str2num(secondsStr);

