%bin_save Save data to headerless binary file (as used by comma).
%   data = bin_save(DATA,FILENAME,FORMAT) saves data to file with raw data
%       types specified by the format string.
%
%       DATA                     The matrix of data to save to the file.
%                                that will contain the raw binary data.
%       FILENAME                 The string file name for the file that
%                                will contain the raw binary data.
%       FORMAT                   A string specifying the data types in the
%                                file. 
%
%           't':        timestamp*
%           'd':        64 bit float
%           'f':        32 bit float
%           'ul','l:    64 bit unsigned/signed integer
%           'ui','i:    32 bit unsigned/signed integer
%           'uw','w:    16 bit unsigned/signed integer
%           'ub','b:    8 bit unsigned/signed integer
%           'c','i:     8 bit char
%
%           * timestamp interpreted as a double representing seconds since
%           epoch, automatically converted to a 64 bit unsigned int
%           representing microseconds since epoch.
%
%   Examples:
%
%       bin_save(data, 'data.bin', 'd,d,ui,w') %save data to 'data.bin'.
%       % data must be will be Nx4 to match the format string. This will
%       % create a file that contains N entries (rows), where each entry
%       % has two doubles, an unsigned int (32 bit) and a word
%       % (signed 16 bit integer)
%
% This file is part of comma, a generic and flexible library
% Copyright (c) 2011 The University of Sydney
% All rights reserved.
%
% author James Underwood
function []=bin_save(data,filename,format_string)

c = textscan(format_string, '%s', 'delimiter', ',');

if length(c{1})~=size(data,2)
    error( sprintf('cols in data (%d) ~= entries in format string (%d)',size(data,2),length(c{1})) )
end

format = struct('str',{{}},'bytes',[],'mstr',{{}});
bytes=[];
for i = 1:length(c{1})
    if strcmp(c{1}{i},'t')
        format.mstr{end+1}='uint64';
        format.bytes(end+1)=8;
    elseif strcmp(c{1}{i},'d')
        format.mstr{end+1}='float64';
        format.bytes(end+1)=8;
    elseif strcmp(c{1}{i},'f')
        format.mstr{end+1}='float32';
        format.bytes(end+1)=4;
    elseif strcmp(c{1}{i},'ul')
        format.mstr{end+1}='uint64';
        format.bytes(end+1)=8;
    elseif strcmp(c{1}{i},'l')    
        format.mstr{end+1}='int64';
        format.bytes(end+1)=8;
    elseif strcmp(c{1}{i},'ui')
        format.mstr{end+1}='uint32';
        format.bytes(end+1)=4;
    elseif strcmp(c{1}{i},'i')
        format.mstr{end+1}='int32';
        format.bytes(end+1)=4;
    elseif strcmp(c{1}{i},'uw')
        format.mstr{end+1}='uint16';
        format.bytes(end+1)=2;
    elseif strcmp(c{1}{i},'w')
        format.mstr{end+1}='int16';
        format.bytes(end+1)=2;
    elseif strcmp(c{1}{i},'ub')
        format.mstr{end+1}='uint8';
        format.bytes(end+1)=1;
    elseif strcmp(c{1}{i},'b')
        format.mstr{end+1}='int8';
        format.bytes(end+1)=1;
    elseif strcmp(c{1}{i},'c')
        format.mstr{end+1}='uchar';
        format.bytes(end+1)=1;
    else
        error(sprintf('unsupported format type: %s', c{1}{i}));
    end
    format.str{end+1}=c{1}{i};
end

%convert timestamps
for i = 1:length(c{1})
    if strcmp(c{1}{i},'t')
        data(:,i) = data(:,i).*1e6;
    end
end

f=fopen(filename,'wb');
if( f==-1 )
    error(['could not open file: ', filename]);
end

%write data
%SKIP option in fwrite skips first then writes. Need to preload first entry
for i = 1:length(format.str)
    fwrite(f,data(1,i),format.mstr{i});
end
%now write the rest
for i = 1:length(format.str)
    fseek(f,sum(format.bytes(1:i)),'bof'); %might cause an error if there is only one entry
    fwrite(f,data(2:end,i),format.mstr{i},sum(format.bytes)-format.bytes(i))';
end
fclose(f);

%get file size
fileinfo=dir(filename);
fsize=fileinfo.bytes;
assert( fsize==size(data,1).*sum(format.bytes) )


% This file is part of comma, a generic and flexible library
% Copyright (c) 2011 The University of Sydney
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 1. Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
% 2. Redistributions in binary form must reproduce the above copyright
%    notice, this list of conditions and the following disclaimer in the
%    documentation and/or other materials provided with the distribution.
% 3. All advertising materials mentioning features or use of this software
%    must display the following acknowledgement:
%    This product includes software developed by the The University of Sydney.
% 4. Neither the name of the The University of Sydney nor the
%    names of its contributors may be used to endorse or promote products
%    derived from this software without specific prior written permission.
%
% NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
% GRANTED BY THIS LICENSE.  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
% HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED
% WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
% OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
% IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
