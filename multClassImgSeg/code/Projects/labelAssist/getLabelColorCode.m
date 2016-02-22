function [className classColor] = getLabelColorCode(colorFileDefPath)


fid = fopen(colorFileDefPath);
C = textscan(fid, '%s%s%s%f%f%f');
fclose(fid);

className = C{3};
classColor = [C{4} C{5} C{6}];