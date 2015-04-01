function [ numClassified , totalPoints ] = ClassificationRatePixel(img, trunkij, figure_handle, meanPatch, ZCAWhite, stackedAEOptTheta, numClasses, netconfig)
% function [ numClassified , totalPoints ] = ClassificationRatePixel(img,
% trunkij, figure_handle, meanPatch, ZCAWhite, stackedAEOptTheta,
% numClasses, netConfig)
% Variant of ClassificationRateImageMask. No longer need pre-classified
% images, the classification is done on the go using the pre-build models. 

% Dialate the input points
maskArray = zeros(size(img(:,:,1)));
maskArray(sub2ind(size(maskArray),trunkij(:,2),trunkij(:,1))) = 1;
maskArrayDialated = imerode(imdilate(maskArray,strel('disk',10)),strel('disk',5));
totalPoints = sum(maskArrayDialated(:));

% Get the index vales of the points that need to be classified
[a,b] = ind2sub(size(maskArray),find(maskArrayDialated==1));
queryPoints = [a,b];

% Get class at query points
[class, classProb] = classifyIndividualPixels(im2double(img),queryPoints,meanPatch, ZCAWhite, stackedAEOptTheta, numClasses, netconfig);
% classified as 1 and 2, change to 0-1
class = class-1;
% Probability threshold
prob_threshold = 0.90;
class(classProb < prob_threshold & class==1) = 0;

% Reamp classes into an image
classifiedPoints = zeros(size(maskArray));
trueClassPoints = queryPoints(class==1,:);
classifiedPoints(sub2ind(size(classifiedPoints),trueClassPoints(:,1),trueClassPoints(:,2))) = 1;

% Mask out the classified image outside a certain region
cropImg = [380 889 1050 1339]; % just keep the bottom parts of the classified image
classifiedPoints(1:cropImg(3)-1,:) = 0;
classifiedPoints(cropImg(4)+1:end,:) = 0;
classifiedPoints(:,1:cropImg(1)-1) = 0;
classifiedPoints(:,cropImg(2)+1:end) = 0;

% Total number of points
numClassified = sum(classifiedPoints(:));

if figure_handle
    % have fed through a figure handle and there will be plotting
    set(0,'currentfigure',figure_handle)
    clf('reset')
    h = imadjust(imshow(im2double(img)));
    hold on;
    red = cat(3,ones(size(maskArray)),zeros(size(maskArray)),zeros(size(maskArray)));
    h2 = imshow(red);
    green = cat(3,zeros(size(maskArray)),ones(size(maskArray)),zeros(size(maskArray)));
    h3 = imshow(green);
    hold off;
    set(h2,'AlphaData',maskArrayDialated*0.4);
    set(h3,'AlphaData',ceil(classifiedPoints)*0.3);
    keyboard;
end
