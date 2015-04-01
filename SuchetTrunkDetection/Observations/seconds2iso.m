% SECONDS2ISO Convert format of time from seconds since epoch to iso string
%
%   time_as_iso_string = SECONDS2ISO( time_as_seconds_since_epoch ) converts 
%   between these two formats
%
%   Example
%   -------
%   iso2seconds('20140513T084553.498385')
%
%   See also: iso2seconds
%
%   author James Underwood
function [ iso_string ] = seconds2iso( seconds )
[~, iso_string] = dos(sprintf('echo %f| csv-time --to-iso-string',seconds));
iso_string=iso_string(1:end-1); %strip cr
end
