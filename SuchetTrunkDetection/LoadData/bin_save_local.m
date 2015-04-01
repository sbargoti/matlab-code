function [] = bin_save_local(data,filePath,format_string)
% function [] = bin_save_local(data,filePath,format_string)
% A slight variant of bin_save. The file is initially written locally and
% then transferred to the destination
% Produces much faster results when dealing with files in a network shared
% drive
% see help bin_save for more information

% Get the different file parts
[destFolder,fileName,ext] = fileparts(filePath);

% Save the file locally
bin_save(data,[fileName ext],format_string);

% If destination folder is elsewhere then move the file to the location
if ~isempty(destFolder)
    movefile([fileName ext],filePath)
end