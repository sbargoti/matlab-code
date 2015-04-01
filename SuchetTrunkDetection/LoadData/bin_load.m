%bin_load Load headerless binary data (as used by comma) into workspace.
%   data = bin_load(FILENAME,FORMAT) loads the variables from a file into a
%   double-precision array, with raw data types specified by the format
%   string.
%
%       FILENAME                 The string file name for the file
%                                containing raw binary data.
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
%           * timestamp interpreted as a 64 bit unsigned int, representing 
%           microseconds since epoch, automatically converted to a double
%           representing seconds since epoch.
%
%   Examples:
%
%       data = bin_load('data.bin', 'd,d,ui,w') %load data from 'data.bin'.
%       % data will be Nx4, for a file containing N entries (rows), where
%       % each entry has two doubles, an unsigned int (32 bit) and a word
%       % (signed 16 bit integer)
%
% This file is part of comma, a generic and flexible library
% Copyright (c) 2011 The University of Sydney
% All rights reserved.
%
% author James Underwood
function [data]=bin_load(filename,format_string)

c = textscan(format_string, '%s', 'delimiter', ',');
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
    
entrysize= sum(format.bytes);

f=fopen(filename,'r');
if( f==-1 )
    error(['could not open file: ', filename]);
end

%get file size
fileinfo=dir(filename);
fsize=fileinfo.bytes;
if fsize < entrysize
    fclose(f);
    error(sprintf('file %s with %d bytes, contains fewer than one entry (entrysize: %d)',filename,fsize,entrysize));
end

%get number of entries for preallocation
if( mod(fsize,entrysize)~=0 )
    fclose(f);
    error( sprintf('filesize does not match entry size: remainder = %d bytes', mod(fsize,entrysize)) )
end
entries=fsize/entrysize;

data=zeros(entries,length(format.str));

%read data
for i = 1:length(format.str)
    data(:,i) = fread(f,entries,format.mstr{i},sum(format.bytes)-format.bytes(i))';
    fseek(f,sum(format.bytes(1:i)),'bof'); %might cause an error if there is only one entry
end
fclose(f);

for i = 1:length(c{1})
    if strcmp(c{1}{i},'t')
        data(:,i) = data(:,i)./1e6;
    end
end

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
