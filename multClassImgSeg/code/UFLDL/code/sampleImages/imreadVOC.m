function currentImage = imreadVOC(resizeF, imageChannels, imFileInName, method)

% resizeF = 0.08;

currentImage = imread(imFileInName);
currentImage = double(imresize(currentImage, resizeF, method));


if imageChannels == 3
    currentImage = currentImage/255;
elseif imageChannels == 1
    currentImage = sum(currentImage,3)/3/255;
end

