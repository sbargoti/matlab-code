function [data] = bin_load_local(filePath,format_string)
% function [data] = bin_load_local(filename,format_string)
% A slight variant of bin_load. The file is moved locally and then read
% Produces much faster results when dealing with files in a network shared
% drive
% see help bin_save for more information

% Get the different file parts
[sourceFolder,fileName,ext] = fileparts(filePath);

% If the source folder is elsewhere then move the file to the current location
if ~isempty(sourceFolder)
    copyfile(filePath, [fileName ext])
end

% load the local file
data = bin_load([fileName ext],format_string);

% delete the local file
if ~isempty(sourceFolder)
    delete([fileName ext]);
end
