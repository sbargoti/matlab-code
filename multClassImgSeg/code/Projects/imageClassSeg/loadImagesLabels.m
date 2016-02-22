function [imageData, labelData, labelIdx] = loadImagesLabels(imageDataPath, labelDataPath, classColour)

%% find all images
% every image in the dataset
imType = {'*.jpg', '*.png', '*.bmp'};
% fullFileList = dir([imageDataPath '*jpg']);
for i = 1:length(imType)
    fullFileList = dir([imageDataPath imType{i}]);
    if (~isempty(fullFileList))
        imTypeIdx = i;
        fprintf('Image Type %s\n',imType{i});
        break
    end
end
if isempty(fullFileList)
    disp('Error: Image folder empty')
end

%% find all labels
% image with existing labels
labelFileList = dir([labelDataPath '*png']); % obtain label list
subFileList = labelFileList; % initialise
for i = 1:length(labelFileList)
%     subFileList(i).name = [labelFileList(i).name(1:8) '.jpg'];
    subFileList(i).name = [labelFileList(i).name(1:end-6) imType{2}(2:end)];

end

%% find images with labels
[commonFlag] = compareFileList(subFileList, fullFileList);

%% load every image
currentImage = imread([imageDataPath fullFileList(1).name]);
numIm = size(fullFileList,1);
[imDim1 imDim2 nChannels] = size(currentImage);
imageDataFull = zeros(imDim1,imDim2,nChannels,numIm);

tic;fprintf('Load Full Image set: \n');
for imNo = 1:numIm    
    currentImage = imread([imageDataPath fullFileList(imNo).name]); 
    imageDataFull(:,:,:,imNo) = double(currentImage)/255;
    
    if toc>1
        fprintf('image: %d\n',imNo);tic;
    end
end

%% load label
currentLabel = imread([labelDataPath labelFileList(1).name]);
% currentImage = double(imread([imageDataPath subFileList(1).name]))/255;

numIm = size(labelFileList,1);
[imDim1 imDim2 nChannels] = size(currentLabel);
% imageData = zeros(imDim1,imDim2,nChannels,numIm);
labelData = zeros(imDim1,imDim2,numIm);

tic;fprintf('Load labels: \n');
for imNo = 1:numIm
    
    currentLabel = imread([labelDataPath labelFileList(imNo).name]);
%     currentImage = imread([imageDataPath subFileList(imNo).name]);    
 
    labelData(:,:,imNo) = labelImg2labelNo(currentLabel, classColour);
%     imageData(:,:,:,imNo) = double(currentImage)/255; % normalise

    if toc > 1
    fprintf('Label no: %d\n',imNo);tic;
    end
end

%% seperate image with and without labels

imageData = imageDataFull;
labelIdx = find(commonFlag == 1);

% imageData = imageDataFull(:,:,:,find(commonFlag == 1));
% unlblImageData = imageDataFull(:,:,:,find(commonFlag == 0));

% figure;imagesc(labelData(:,:,30))
% figure;imagesc(imageData(:,:,:,30))




end





function [commonFlag] = compareFileList(subset, fullset)

nFile = length(fullset);

commonFlag = zeros(1,nFile);

nSubFile = length(subset);
iSubFile = 1;

for iFile = 1:nFile
    
%     subset(iSubFile).name
%     fullset(iFile).name
    commonFlag(iFile) = strcmp(subset(iSubFile).name, fullset(iFile).name);
%     commonFlag(iFile)
    if commonFlag(iFile) && (iSubFile < nSubFile)
        iSubFile = iSubFile + 1;
    elseif iSubFile > nSubFile
        break
    end
    
end
% 
% commonIdx = find(commonFlag==1);
% umcommonIdx = find(commonFlag==0);
end
