function [imData] = labelNo2labelImg(label, classColour)
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
% 0	0	256];


[imDim1 imDim2] = size(label);
imData = zeros(imDim1,imDim2,3);
imDataR = zeros(imDim1,imDim2);
imDataG = zeros(imDim1,imDim2);
imDataB = zeros(imDim1,imDim2);

nClasses = size(classColour,1);
for iClass = 1:nClasses

    classPixel = (label == iClass);
    imDataR(classPixel==1) = classColour(iClass,1);
    imDataG(classPixel==1) = classColour(iClass,2);
    imDataB(classPixel==1) = classColour(iClass,3);
    
end

imData(:,:,1) = imDataR;
imData(:,:,2) = imDataG;
imData(:,:,3) = imDataB;

imData = uint8(imData);

end