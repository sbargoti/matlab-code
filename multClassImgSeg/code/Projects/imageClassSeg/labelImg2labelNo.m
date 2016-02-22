function [label] = labelImg2labelNo(imData, classColour)
% label colour lookup

% = d Void	0 	0 	0
% = 1 leaves	64 128 64
% = 2 almonds     128 0 0
% = t trunk	128 128 0
% = g ground	192 192 128
% = s sky	0	0	256

% classColour = [0 	0 	0
% 64 128 64
% 128 0 0
% 128 128 0
% 192 192 128
% 0	0	255];

[imDim1 imDim2 imDim3] = size(imData);
label = zeros(imDim1,imDim2);
nClasses = size(classColour,1);
for iClass = 1:nClasses
    classPixel = (imData(:,:,1) == classColour(iClass,1)).*...
    (imData(:,:,2) == classColour(iClass,2)).*...
    (imData(:,:,3) == classColour(iClass,3)); 

    label(classPixel==1) = iClass;
    
end

test = 1;


end