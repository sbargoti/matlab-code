function [ numClassified , totalPoints ] = ClassificationRateImageMask(img, trunkij, classifiedImgPath,figure_handle)
% function [ numClassified , totalPoints ] = ClassificationRateImageMask(img, trunkij, classifiedImgPath,figure_handle)
% relies on classified images to be present in the classifiedImgPath

% Load classified img
classifiedImg = im2double(imread(classifiedImgPath));

% Mask out the classified image outside a certain region
cropImg = [380 889 1050 1339]; % just keep the bottom parts of the classified image
classifiedImg(1:cropImg(3)-1,:) = 0;
classifiedImg(cropImg(4)+1:end,:) = 0;
classifiedImg(:,1:cropImg(1)-1) = 0;
classifiedImg(:,cropImg(2)+1:end) = 0;

% Create mask from the trunkij points
maskArray = zeros(size(img(:,:,1)));
maskArray(sub2ind(size(maskArray),trunkij(:,2),trunkij(:,1))) = 1;
maskArrayDialated = imerode(imdilate(maskArray,strel('disk',10)),strel('disk',5));
totalPoints = sum(maskArrayDialated(:));
% imshow(img.*uint8(repmat(maskArrayDialated,[1,1,3])));

% Get the points that are classified as trunk
classifiedPoints = ceil(maskArrayDialated.*classifiedImg);
numClassified = sum(classifiedPoints(:));


if nargin == 4
    % have fed through a figure handle and there will be plotting
    set(0,'currentfigure',figure_handle)
    clf('reset')
    h = imshow(im2double(img));
    hold on;
    red = cat(3,ones(size(maskArray)),zeros(size(maskArray)),zeros(size(maskArray)));
    h2 = imshow(red);
    green = cat(3,zeros(size(maskArray)),ones(size(maskArray)),zeros(size(maskArray)));
    h3 = imshow(green);
    hold off;
    set(h2,'AlphaData',maskArrayDialated*0.4);
    set(h3,'AlphaData',ceil(classifiedPoints)*0.3);
end