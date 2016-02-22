function [RGBimageData IRimageData labelData labelIdx unlabelIdx classNameList] = loadRGBIRLabels(RGBDataPath, IRDataPath, labelDataPath)

% every image in the dataset
fullRGBFileList = dir([RGBDataPath '*jpg']);

% image with existing labels
labelFileList = dir([labelDataPath '*png']); % obtain label list
subFileList = labelFileList; % initialise
for i = 1:length(labelFileList)
%     subFileList(i).name = [labelFileList(i).name(1:8) '.jpg'];
    subFileList(i).name = [labelFileList(i).name(1:13) '.jpg'];

end

% find RGB images with labels
[commonFlag] = compareFileList(subFileList, fullRGBFileList);

% load every RGB image
currentImage = imread([RGBDataPath fullRGBFileList(1).name]);
numIm = size(fullRGBFileList,1);
[imDim1 imDim2 nChannels] = size(currentImage);
RGBimageData = zeros(imDim1,imDim2,nChannels,numIm);

tic;fprintf('Load Full RGB Image set: \n');
for imNo = 1:numIm    
    currentImage = imread([RGBDataPath fullRGBFileList(imNo).name]); 
    RGBimageData(:,:,:,imNo) = double(currentImage)/255;
    
    if toc>1
        fprintf('image: %d\n',imNo);tic;
    end
end

fullIRFileList = fullRGBFileList;

% load every NIR image
IRimageData = zeros(imDim1,imDim2,nChannels,numIm);

RGB2IRImIdx = ...
    [2053 2050
    2054 2051
    2055 2052
    2056 2059
    2057 2060
    2058 2061
    2065 2062
    2066 2063
    2067 2064
    2044 2047
    2045 2048
    2046 2049
    2041 2038
    2042 2039
    2043 2040
    2032 2035
    2033 2036
    2034 2037
    2029 2026 
    2030 2027
    2031 2028
    2068 2071
    2069 2072
    2070 2073];

tic;fprintf('Load Full IR Image set: \n');
for imNo = 1:numIm    
    RGBimgidx = str2num(fullRGBFileList(imNo).name(5:8)); % get RGB image number
    IRimgidx  = RGB2IRImIdx(find(RGB2IRImIdx(:,1)==RGBimgidx),2); % map to IR image number
    fullIRFileList(imNo).name(5:8) = num2str(IRimgidx); % write to the IR image name
    
    currentImage = imread([IRDataPath fullIRFileList(imNo).name]);
    IRimageData(:,:,:,imNo) = double(currentImage)/255;
    
    if toc>1
        fprintf('image: %d\n',imNo);tic;
    end
end



% load label
currentLabel = imread([labelDataPath labelFileList(1).name]);
numIm = size(labelFileList,1);
[imDim1 imDim2 nChannels] = size(currentLabel);
labelData = zeros(imDim1,imDim2,numIm);

tic;fprintf('Load labels: \n');
for imNo = 1:numIm
    
    currentLabel = imread([labelDataPath labelFileList(imNo).name]);

    labelData(:,:,imNo) = labelImg2labelNo(currentLabel);

    if toc > 1
    fprintf('Label no: %d\n',imNo);tic;
    end
end

labelData(labelData==0) = 1; % somehow there are 3 zeros in the label data?

labelIdx = find(commonFlag == 1);
unlabelIdx = find(commonFlag == 0);


% figure;imagesc(labelData(:,:,30))
% figure;imagesc(imageData(:,:,:,30))


% = d Void	0 	0 	0
% = 1 leaves	64 128 64
% = 2 almonds     128 0 0
% = t trunk	128 128 0
% = g ground	192 192 128
% = s sky	0	0	256

classNameList = ...
{'Void      ',...
 'leaves	',...
 'almonds	',...
 'trunk     ',...
 'ground	',...
 'sky       '};

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
    elseif iSubFile == nSubFile
        break
    end
    
end
% 
% commonIdx = find(commonFlag==1);
% umcommonIdx = find(commonFlag==0);
end
