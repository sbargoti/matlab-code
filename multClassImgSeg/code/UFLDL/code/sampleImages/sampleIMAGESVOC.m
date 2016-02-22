function patches = sampleIMAGESVOC(resizeF, patchsize, imageChannels, numpatches)

%% Internal Paramters

imagePath = 'D:\Work\dataSet\VOC2011\JPEGImages'; %(on my comp)
% imagePath = '/nethome/calvin/dataSet/VOC2011/JPEGImages';  % (on archipelago)


% imagePath = VOCopts.imgpath;
% imagePath = 'H:\Work\dataSet\juliaCreekImage\flight12_2009_18_7';
% imagePath = 'H:\Work\dataSet\googleEarth';

fileName = dir([imagePath '/*.jpg'])
numImages = length(fileName)

% entropy rejection

if imageChannels == 3
    entThreshold = 4;
elseif imageChannels == 1
    entThreshold = 0.5;
end

%% trainImages arrary

% initialise arrary

imageName = fileName(1,1).name(1:end-4); % get rid of .png extension
currentFileInName = [imagePath '/' imageName '.jpg'];

currentImage = imreadVOC(resizeF, imageChannels, currentFileInName, 'bicubic');


patches = zeros(patchsize*patchsize*imageChannels, numpatches);

numPatchesPerImage = 100;
numTrainImages = numpatches/numPatchesPerImage;

disp('Collecting training images from VOC image data set')
tic
for i = 1:numTrainImages
  
    imageNo = randi([1, numImages]);   
    
    imageName = fileName(imageNo,1).name(1:end-4); % get rid of .png extension    
    currentFileInName = [imagePath '/' imageName '.jpg'];
    currentImage = imreadVOC(resizeF, imageChannels, currentFileInName, 'bicubic');


%     currentImage = imread(currentFileInName);
%     currentImage = double(imresize(currentImage, resizeF))/255;       
    
    [dim1 dim2 dim3] = size(currentImage);
    
    % valid image range
    dim1Lim = dim1 - patchsize;
    dim2Lim = dim2 - patchsize;
    
    for j=1:numPatchesPerImage
        
        ent = 0;
        
        while ent < entThreshold        
        coord1 = ceil(rand*dim1Lim);   % randomly start coordinate 1
        coord2 = ceil(rand*dim2Lim);   % randomly start coordinate 2
        coord1END = coord1 + patchsize -1;
        coord2END = coord2 + patchsize -1;
        
        imagePatch = currentImage(coord1:coord1END, ...
            coord2:coord2END,:);
        
        ent = entropy(imagePatch);
        end
        
        k = (i-1)*numPatchesPerImage +j;
        patches(:,k) = imagePatch(:);
        
    end
        
    if toc>5
%         fprintf('test confusion: %d/%d\n',i,length(gtids));
fprintf('%i/%i \n', k,numpatches);
        drawnow;
        tic;
    end
%     if rem(i,10) == 0
%         fprintf('%i/%i \n', i,numTrainImage);
%     end
end
disp('Done collecting training images from VOC image data set')


reshuffleOrder = randperm(size(patches,2));
patches = patches(:,reshuffleOrder);
% displayColorNetwork(patches(:, 1:100));
% display_network(patches(:, 1:100));
save patchTest patches
end


