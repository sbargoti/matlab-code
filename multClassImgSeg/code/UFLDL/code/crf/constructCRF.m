function [ims, labels, labels0, feats, efeats, models]=constructCRF(imageData, labelData, targetIdx, UnaryPara, rez)

stackedAEOptTheta = UnaryPara.stackedAEOptTheta;
patchsize         = UnaryPara.patchsize;
hiddenSizeL1      = UnaryPara.hiddenSizeL1;
numClasses        = UnaryPara.numClasses;
netconfig         = UnaryPara.netconfig;
ZCAWhite          = UnaryPara.ZCAWhite;
meanPatch         = UnaryPara.meanPatch;
resizeF           = UnaryPara.resizeF;
locationFeatFlag  = UnaryPara.locationFeatFlag;


nScale = length(resizeF);
% nvals  = numClasses+1;
nvals  = numClasses;


targetImgData = imageData(:,:,:,targetIdx);
targetLblData = labelData(:,:,targetIdx);

nImage = size(targetImgData,4);
ims    = cell(nImage,1);
labels = cell(nImage,1);
labels0 = cell(nImage,1);
feats = cell(nImage,1);


%for iTrainImage = 1:N
for iImage = 1:nImage    
    
%     orgImage = targetImgData(:,:,:,iImage)/255;
    orgImage = targetImgData(:,:,:,iImage);
    orgSegLabel = targetLblData(:,:,iImage);
    for scaleI = 1:nScale
        currentImage{scaleI} = double(imresize(orgImage, resizeF(scaleI), 'bicubic'));
        currentSegLabel{scaleI} = double(imresize(orgSegLabel, resizeF(scaleI), 'nearest'));
    end
    
    [predLImg, imFeatResp, hypothesis] = stackedAELinearImgPredict(stackedAEOptTheta, patchsize, hiddenSizeL1, ...
        numClasses, netconfig, currentImage, ZCAWhite, meanPatch, resizeF, locationFeatFlag);
    
    
    % load data
    
    ims{iImage}  = orgImage;
    labels0{iImage} = orgSegLabel;
    
    % compute features
    feats{iImage}  = imFeatResp;
    
    % reduce resolutioiTrainImage for speed
    ims{iImage}    = imresize(ims{iImage}   ,rez,'bilinear');
    feats{iImage}  = imresize(feats{iImage} ,rez,'bilinear');
    labels{iImage} = imresize(labels0{iImage},rez,'nearest');
    
    % reshape features
    [ly lx lz] = size(feats{iImage});
    feats{iImage} = reshape(feats{iImage},ly*lx,lz);
    iImage
end

% the images come in slightly different sizes, so we need to make many models
% use a "hashing" strategy to not rebuild.  Start with empty giant array
model_hash = repmat({[]},1000,1000);
fprintf('building models...\n')
for n=1:nImage
    [ly lx lz] = size(ims{n});
    if isempty(model_hash{ly,lx});
        model_hash{ly,lx} = gridmodel(ly,lx,nvals);
    end
    n
end
models = cell(nImage,1);
for n=1:nImage
    [ly lx lz] = size(ims{n});
    models{n} = model_hash{ly,lx};
    n
end

fprintf('computing edge features...\n')
edge_params = {{'const'},{'diffthresh'},{'pairtypes'}};
efeats = cell(nImage,1);
parfor n=1:nImage
    efeats{n} = edgeify_im(ims{n},edge_params,models{n}.pairs,models{n}.pairtype);
    n
end
