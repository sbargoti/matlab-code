function converted_string = os_filename(raw_string)
% Convert an input string - path; to an os dependednt string

% Handle linux and latex file parts
raw_string = strrep(raw_string, '/', filesep);
if ~ispc
    raw_string = strrep(raw_string, '\', filesep);
end

converted_string = raw_string;