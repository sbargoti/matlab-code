% mainMultiClassImageSegTrain
%
% training model for multi-class image segmentation
% specify the directory of the labelled images, also put the
% DefaultLabelNames.txt file in the same directory
% site: ACFR AMME USYD 
% date: 28 Jan 2014
% author: Calvin Hung 
dbstop if error

%% Initialisation
currentPath = cd;
rootPath = currentPath(1:(strfind(currentPath,'multClassImgSeg')+15)); % to multClassImgSeg/

dataPath = ['C:\work\data\raw\2013-10-08-melbourne-apples\shrimp\e20-24-i-row\ladybug\e20_1\labelledData\sml\']; %train data path
imageDataPath = [dataPath 'images\'];
labelDataPath = [dataPath 'labels\'];

trainMode = 1; % 1:algorithm evalution (half train half eval), 2:algorithm application (use all labels to learn model)


%% Libraries

% image segmentation common
addpath( [rootPath 'code\Projects\imageClassSeg\']);
addpath( [rootPath 'code\Projects\labelAssist\']); % add the get label color code

% unsupervised feature learning and deep learning
ufldlPath = [rootPath 'code/UFLDL/code/'];
addpath( [ufldlPath 'displayNetwork'])
addpath( [ufldlPath 'minFunc'])
addpath( [ufldlPath 'sparseAutoencoder'])
addpath( [ufldlPath 'linear_decoder'])
addpath( [ufldlPath 'softmax']) % for softmax train
addpath( [ufldlPath 'stl']) % for feedforward autoencoder
addpath( [ufldlPath 'cnn']) %
addpath( [ufldlPath 'stackedae'])
addpath( [ufldlPath 'multiScaleUFL'])
addpath( [ufldlPath 'numericalGradient'])
addpath( [ufldlPath 'sampleImages'])
addpath( [ufldlPath 'crf'])
addpath( [ufldlPath 'kmeans_demo'])

% % JGMT2 (for CRF training)
% ugmPath = [rootPath 'code/JGMT2/JustinsGraphicalModelsToolboxPublic'];
% addpath(genpath(ugmPath))

% my awesome conf matrix and class accuracy display fn
addpath( [rootPath 'code/usefulFns']);


%% 0 Algorithm Setting

% numPatches = 400000;
numPatches = 1000000;
numLaebelledPatches = 300000;

nband = 3; % number of channels (rgb, so 3)
% nband = 4;

patchsize = 8;
% patchsize = 7;

inputSize = patchsize * patchsize * nband;
visibleSize = inputSize;  % number of input units
outputSize  = visibleSize;   % number of output units
hiddenSizeL1  = 50;           % number of hidden units (layer one: linear sparse autoendoer)
% hiddenSizeL1  = 144;           % number of hidden units (layer one: linear sparse autoendoer)
% hiddenSizeL2  = 200;           % number of hidden units (layer two: sparse autoencoder)
% hiddenSizeL3  = 400;           % number of hidden units (layer three: sparse autoencoder)

sparsityParam = 0.035; % desired average activation of the hidden units.
lambda = 3e-3;         % weight decay parameter
beta = 5;              % weight of sparsity penalty term

epsilon = 0.1;	       % epsilon for ZCA whitening

resizeF = [1 1/2 1/4 1/8];

nScale = length(resizeF);


%% load training dataset

colorFileDefPath = [dataPath 'DefaultLabelNames.txt'];
[classNameList, classColour] = getLabelColorCode(colorFileDefPath);

[imageData, labelData] = loadImagesLabels(imageDataPath ,labelDataPath , classColour);

labelledImageData = imageData;

imNo = 5;
figure;imagesc(imageData(:,:,:,imNo));title('RGB');axis off;axis image
figure;imagesc(labelData(:,:,imNo));title('RGB');axis off;axis image

validClassIdx = unique(labelData(:));

%% for unsupervised feature learning 

% load pre-learned filters
load sae1OptThetaRGB
% load sae1OptThetaRGB7x7

%% 3.1: supervised learning with labels

if trainMode == 1 % algorithm evaluation
    dataSize = size(labelledImageData,4);
    trainIdx = randsample(dataSize,ceil(dataSize/2));
    testIdx = setdiff([1:dataSize],trainIdx);
    save test_trainIdx testIdx trainIdx
    
elseif trainMode == 2 % algorithm application 
    dataSize = size(labelledImageData,4);
    trainIdx = [1:dataSize];
    testIdx = [1:dataSize];

end

%%
% load test_trainIdx

trainData  = labelledImageData(:,:,:,trainIdx);
trainLabel = labelData(:,:,trainIdx);
testData  = labelledImageData(:,:,:,testIdx);
testLabel = labelData(:,:,testIdx);
%%

unique(trainLabel)
unique(testLabel)

fprintf('Sampling Training Examples\n');
[trainPatches trainLocations trainPatchLabels]...
    = sampleMultiScalePatchLabel(trainData, trainLabel, resizeF, patchsize, numLaebelledPatches);

fprintf('Sampling Testing Examples\n');
[testPatches testLocations testPatchLabels]...
    = sampleMultiScalePatchLabel(testData, testLabel, resizeF, patchsize, numLaebelledPatches);


reshuffleOrder = randperm(size(trainPatches,4));
trainPatches = trainPatches(:,:,:,reshuffleOrder,:);
trainPatchLabels = trainPatchLabels(:,reshuffleOrder);
trainLocations = trainLocations(:,reshuffleOrder);
% tempTrainImage = zeros(patchsize*patchsize*3,size(trainPatches,4));
tempTrainImage = zeros(patchsize*patchsize*nband,size(trainPatches,4),nScale);
trainPatchesV = zeros(patchsize*patchsize*nband,size(trainPatches,4),nScale);
trainPatchesVW = zeros(patchsize*patchsize*nband,size(trainPatches,4),nScale);
testPatchesV = zeros(patchsize*patchsize*nband,size(testPatches,4),nScale);
testPatchesVW = zeros(patchsize*patchsize*nband,size(testPatches,4),nScale);
for j = 1: nScale
    for i = 1:size(trainPatches,4)
        tempTrainImage(:,i,j) = reshape(trainPatches(:,:,:,i,j),[1 patchsize*patchsize*nband]);
    end
    figure;displayColorNetwork( tempTrainImage(1:patchsize*patchsize*3,1:400,j));
    
    fprintf('Whiten Training Samples, iScale = %i/%i \n', j, nScale);
    [trainPatchesV(:,:,j) trainPatchesVW(:,:,j)] =...
        vec_white_image(trainPatches(:,:,:,:,j), meanPatch(:,j), ZCAWhite(:,:,j));
    
    fprintf('Whiten Testing Samples, iScale = %i/%i \n', j, nScale);
    [testPatchesV(:,:,j) testPatchesVW(:,:,j)] = ...
        vec_white_image(testPatches(:,:,:,:,j), meanPatch(:,j), ZCAWhite(:,:,j));
    %     [trainPatchesV trainPatchesVW] = vec_white_image(trainPatches, meanPatch, ZCAWhite);
    %     [testPatchesV testPatchesVW] = vec_white_image(testPatches, meanPatch, ZCAWhite);
end

% displayColorNetwork( trainPatchesV(:,1:400));
% displayColorNetwork( trainPatchesVW(:,1:400));
% displayColorNetwork( testPatchesV(:,1:400));
% displayColorNetwork( testPatchesVW(:,1:400));
trainsae1FeaturesResp = zeros(hiddenSizeL1,size(trainPatches,4),nScale);
testsae1FeaturesResp = zeros(hiddenSizeL1,size(trainPatches,4),nScale);
for j = 1: nScale
    
    theta = sae1OptTheta(:,j);
    hiddenSize = hiddenSizeL1;
    visibleSize = inputSize;
    
    data = trainPatchesVW(:,:,j);
    [trainsae1FeaturesResp(:,:,j)] = feedForwardAutoencoder(theta, hiddenSize, visibleSize, data);
    
    data = testPatchesVW(:,:,j);
    [testsae1FeaturesResp(:,:,j)] = feedForwardAutoencoder(theta, hiddenSize, visibleSize, data);
    
end

close all
%% 4.1 supervised pre-training

locationFeatFlag = 0; % don't use the label pixel position as a feature

numClasses = length(unique(labelData));

softmaxY = trainPatchLabels;
softmaxLambda = 1e-4;

% using multiscale feature
% visibleSize = (hiddenSizeL1 + inputSize)*nScale;
visibleSize = (hiddenSizeL1)*nScale;

softmaxX = [];

for j = 1: nScale
    softmaxX = cat(1, softmaxX, trainsae1FeaturesResp(:,:,j));
end

% [softmaxX] = magicNormalisation(softmaxX);

if locationFeatFlag == 1
    % get location into feature too
    softmaxX = cat(1, softmaxX, trainLocations);
end

softmaxFeatureModelMultScale = softmaxTrain(visibleSize,...
    numClasses, softmaxLambda, softmaxX, softmaxY);

saeSoftmaxOptTheta = softmaxFeatureModelMultScale.optTheta(:);

if nband == 3    
    save saeRelatedParaRGB numClasses locationFeatFlag
    save saeSoftmaxOptThetaRGB saeSoftmaxOptTheta
    save softmaxFeatureModelMultScaleRGB softmaxFeatureModelMultScale
elseif nband == 4    
    save saeRelatedParaRGBIR numClasses locationFeatFlag
    save saeSoftmaxOptThetaRGBIR saeSoftmaxOptTheta
    save softmaxFeatureModelMultScaleRGBIR softmaxFeatureModelMultScale
end

%% 

if nband == 3
    load saeRelatedParaRGB
    load saeSoftmaxOptThetaRGB
    load softmaxFeatureModelMultScaleRGB
elseif nband == 4
    load saeRelatedParaRGBIR
    load saeSoftmaxOptThetaRGBIR
    load softmaxFeatureModelMultScaleRGBIR
end

% load locationFeatFlag

%% 4.3 supervised fine tuning

% stack pretrained sparse linear decoder and softmax classifier and
% fine-tune

% visibleSize = inputSize;
% hiddenSize = hiddenSizeL1;
% Initialize the stack using the parameters learned
stack = cell(1,1);
wTmp = [];
bTmp = [];
for iScale = 1:nScale
    wTmp = cat(1, wTmp, reshape(sae1OptTheta(1:hiddenSizeL1*inputSize,iScale), ...
        hiddenSizeL1, inputSize));
    bTmp = cat(1, bTmp, sae1OptTheta(2*hiddenSizeL1*inputSize+1:2*hiddenSizeL1*inputSize+hiddenSizeL1,iScale));
end
stack{1}.w = wTmp;
stack{1}.b = bTmp;
% stack{2}.w = reshape(sae2OptTheta(1:hiddenSizeL2*hiddenSizeL1), ...
%                      hiddenSizeL2, hiddenSizeL1);
% stack{2}.b = sae2OptTheta(2*hiddenSizeL2*hiddenSizeL1+1:2*hiddenSizeL2*hiddenSizeL1+hiddenSizeL2);

% Initialize the parameters for the deep model
[stackparams, netconfig] = stack2params(stack);
stackedAETheta = [ saeSoftmaxOptTheta ; stackparams ];


visibleSize = inputSize;

trainDataSAE = trainPatchesVW;
trainLabelsNorm = trainPatchLabels;

debug = 0;
if debug == 1
    %% check gradient
    subsetIdx = 1:30;
    
    [cost grad] = stackedAELinearCost(stackedAETheta,visibleSize, hiddenSizeL1, ...
        numClasses, netconfig, ...
        lambda, trainDataSAE(:,subsetIdx,:), trainLocations(:,subsetIdx), trainLabelsNorm(subsetIdx), nScale, locationFeatFlag);
    
    numGrad = computeNumericalGradient( @(x) stackedAELinearCost(x, visibleSize, hiddenSizeL1, ...
        numClasses, netconfig, ...
        lambda, trainDataSAE(:,subsetIdx,:), trainLocations(:,subsetIdx), trainLabelsNorm(subsetIdx), nScale, locationFeatFlag), stackedAETheta);
    
    % Use this to visually compare the gradients side by side
    % disp([numGrad grad]);
    
    % Compare numerically computed gradients with those computed analytically
    diff = norm(numGrad-grad)/norm(numGrad+grad);
    disp(diff);
    %%
end


stackedAEModel = stackedAELinearTrain(visibleSize, hiddenSizeL1, numClasses,...
    netconfig, lambda, trainDataSAE, trainLocations, trainLabelsNorm, stackedAETheta, nScale, locationFeatFlag);

% save stackedAEModel stackedAEModel

stackedAEOptTheta = stackedAEModel.optTheta;

if nband == 3    
save stackedRelatedParaRGB stackparams netconfig
save stackedAEThetaRGB stackedAETheta
save stackedAEOptThetaRGB stackedAEOptTheta
save stackedAEModelMultScaleRGB stackedAEModel
elseif nband == 4
save stackedRelatedParaRGBIR stackparams netconfig
save stackedAEThetaRGBIR stackedAETheta
save stackedAEOptThetaRGBIR stackedAEOptTheta
save stackedAEModelMultScaleRGBIR stackedAEModel
end



%% 

if nband == 3    
load stackedRelatedParaRGB
load stackedAEThetaRGB
load stackedAEOptThetaRGB
load stackedAEModelMultScaleRGB
elseif nband == 4
load stackedRelatedParaRGBIR
load stackedAEThetaRGBIR
load stackedAEOptThetaRGBIR
load stackedAEModelMultScaleRGBIR
end


%% 5.1: Results on patch classification


fprintf('hiddenSizeL1 = %d\n', hiddenSizeL1);

 testsae1CatFeaturesResp = [];
%  for j = 1: nScale % put whitten image patches in
%      testsae1CatFeaturesResp = cat(1, testsae1CatFeaturesResp, testImagesVW(:,:,j));
%  end
 for j = 1: nScale % put feature responses in
     testsae1CatFeaturesResp = cat(1, testsae1CatFeaturesResp, testsae1FeaturesResp(:,:,j));
 end

%  [testsae1CatFeaturesResp] = magicNormalisation(testsae1CatFeaturesResp);
 
 if locationFeatFlag == 1
 testsae1CatFeaturesResp = cat(1,testsae1CatFeaturesResp, testLocations);
 end

[predCat] = softmaxPredict(softmaxFeatureModelMultScale, testsae1CatFeaturesResp);

CP = classperf(testPatchLabels,predCat);
acc = CP.CorrectRate;
% acc = mean((testLabels(:)+1) == predCat(:));
fprintf('Classification Accuracy (using multi-scale features and original): %0.3f%%\n', acc * 100);
ConfMatrix = confusionmat(testPatchLabels,predCat);
figure;imagesc(ConfMatrix);
figure;imagesc(CP.CountingMatrix);

%
testDataSAE = testPatchesVW;
testLabelsNorm = testPatchLabels;


[pred] = stackedAELocLinearPredict(stackedAETheta, visibleSize, hiddenSizeL1, ...
                          numClasses, netconfig, testDataSAE, testLocations, nScale, locationFeatFlag);

CP = classperf(testLabelsNorm,pred);
acc = CP.CorrectRate;
fprintf('Classification Accuracy (without fine tuning): %0.3f%%\n', acc * 100);
figure;imagesc(CP.CountingMatrix);


[pred] = stackedAELocLinearPredict(stackedAEOptTheta, visibleSize, hiddenSizeL1, ...
                          numClasses, netconfig, testDataSAE, testLocations, nScale, locationFeatFlag);

CP = classperf(testLabelsNorm,pred);
acc = CP.CorrectRate;
fprintf('Classification Accuracy (with fine tuning): %0.3f%%\n', acc * 100);
figure;imagesc(CP.CountingMatrix);

perClassAcc = 1 - (CP.ErrorDistributionByClass/(CP.NumberOfObservations/numClasses));

for i=1:numClasses
fprintf('%s \t %1.4f\n', classNameList{i}, perClassAcc(i));
end


%% plot ground
patchNo = 5000;
figure;
subplot(2,2,1);imagesc(testPatches(:,:,1:3,patchNo,1))
subplot(2,2,2);imagesc(testPatches(:,:,1:3,patchNo,2))
subplot(2,2,3);imagesc(testPatches(:,:,1:3,patchNo,3))
subplot(2,2,4);imagesc(testPatches(:,:,1:3,patchNo,4))
title(classNameList(testPatchLabels(patchNo)));

%% 5.2: evaluation over entire dataset
[junk junk junk numTestImage] = size(testData);
plotFigFlag = 1;
testPredData = zeros(size(testLabel));
testPredIcmData = zeros(size(testLabel));
testPredCrfData = zeros(size(testLabel));
for iTestImage = 1:numTestImage
    orgImage = testData(:,:,:,iTestImage);
    orgSegLabel = testLabel(:,:,iTestImage);
    for scaleI = 1:nScale
        currentImage{scaleI} = double(imresize(orgImage, resizeF(scaleI), 'bicubic'));
        currentImage{scaleI}(currentImage{scaleI}>1) = 1;
        currentImage{scaleI}(currentImage{scaleI}<0) = 0;
        currentSegLabel{scaleI} = double(imresize(orgSegLabel, resizeF(scaleI), 'nearest'));
    end
    
    [predLImg, imFeatResp, hypothesis] = stackedAELinearImgPredict(stackedAEOptTheta, patchsize, hiddenSizeL1, ...
        numClasses, netconfig, currentImage, ZCAWhite, meanPatch, resizeF, locationFeatFlag);
      
    if plotFigFlag == 1
        figure(1);subplot(2,2,1);imagesc(currentImage{1}(:,:,1:3));
        subplot(2,2,4);imagesc(predLImg);caxis([1 12]);
        subplot(2,2,3);imagesc(currentSegLabel{1});caxis([1 12]);
        subplot(2,2,2);
                
        %         figure(2);imagesc(reshape(ICMDecoding,imDim1,imDim2));caxis([1 12]);
        %         figure(3);imagesc(reshape(alphaBetaDecode,imDim1,imDim2));caxis([1 12]);
        
        pause(0.1);
    end
    
    testPredData(:,:,iTestImage) = predLImg;
    %     testPredIcmData(:,:,iTestImage) = reshape(ICMDecoding,imDim1,imDim2);
    %     testPredCrfData(:,:,iTestImage) = reshape(alphaBetaDecode,imDim1,imDim2);
    iTestImage
end


CPDataset = classperf(testLabel(:),testPredData(:));
acc = sum(testLabel(:)==testPredData(:))/length(testPredData(:));

fprintf('Classification Accuracy (with fine tuning): %0.3f%%\n', acc * 100);
figure;imagesc(CPDataset.CountingMatrix);

perClassAcc = 1 - (CPDataset.ErrorDistributionByClass./(CPDataset.SampleDistributionByClass));

save CPDataset CPDataset
save testPredData testPredData

for i=1:numClasses
    fprintf('%s \t %1.4f\n', classNameList{i}, perClassAcc(i));
end

globalAcc = CPDataset.CorrectRate;

avgClassAcc = sum(perClassAcc)/length(perClassAcc);

myClassifierPerf(CPDataset, validClassIdx, classNameList);

