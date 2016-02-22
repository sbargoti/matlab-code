% mainMultiClassImageSEgPred
%
% multi-class image prediction
% site: ACFR AMME USYD 
% date: 28 Jan 2014
% author: Calvin Hung
dbstop if error

%% Initialisation
currentPath = cd;

rootPath = currentPath(1:(strfind(currentPath,'work')+4)); % to work/

dataPath = ['C:\work\data\raw\2013-10-08-melbourne-apples\shrimp\e20-24-i-row\bumblebee\e20_1\'];
imgFolderName = dataPath

outFolderName = ['C:\work\data\processed\appleFlowerDet\2013-10-08-melbourne-apples\shrimp\e20-24-i-row\bumblebee\e20_1\'];

%% Libraries

addpath(dataPath);

% image segmentation common
addpath( [rootPath 'code\Projects\imageClassSeg\']);

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

% JGMT2
ugmPath = [rootPath 'code/JGMT2/JustinsGraphicalModelsToolboxPublic'];
addpath(genpath(ugmPath))

% my awesome conf matrix and class accuracy display fn
addpath( [rootPath 'code/usefulFns']);


%% 0 Algorithm Settings

numPatches = 1000000;

nband = 3;% number of channels (rgb, so 3)
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

addpath(outFolderName)
imgList = dir([imgFolderName '*.png']);

%% load model

load sae1OptThetaRGB
load saeRelatedParaRGB
load saeSoftmaxOptThetaRGB
load softmaxFeatureModelMultScaleRGB

load stackedRelatedParaRGB
load stackedAEThetaRGB
load stackedAEOptThetaRGB
load stackedAEModelMultScaleRGB

%%

% imNo = 50;
% for imNo = 600:length(imgList)
for imNo = 1:length(imgList)

tic
fprintf('image:%i/%i\n',imNo, length(imgList))
orgImage = im2double(imread([[imgFolderName imgList(imNo).name]]));


for scaleI = 1:nScale
    currentImage{scaleI} = double(imresize(orgImage, resizeF(scaleI), 'bicubic'));
    currentImage{scaleI}(currentImage{scaleI}>1) = 1;
    currentImage{scaleI}(currentImage{scaleI}<0) = 0;
end

[predLImg, imFeatResp, hypothesis] = stackedAELinearImgPredict(stackedAEOptTheta, patchsize, hiddenSizeL1, ...
    numClasses, netconfig, currentImage, ZCAWhite, meanPatch, resizeF, locationFeatFlag);


figure(1);
hAxes1 = subplot(1,2,1);imagesc(currentImage{1}(:,:,1:3));axis image
hAxes2 = subplot(1,2,2);imagesc(squeeze(hypothesis(2,:,:)));axis image;
linkaxes([hAxes1,hAxes2]);


outputImg = squeeze(hypothesis(2,:,:));
% outputImg(1400:end,:) = 0;

% figure;imagesc(outputImg);axis image

outputImgName = [imgList(imNo).name(1:end-3) 'Prob.png'];
imwrite(outputImg, ([outFolderName outputImgName]),'png');

toc;

end

% %% morphological operation
% se = strel('disk',5);
% appleSegments = imerode(appleSegments,se);
% se = strel('disk',10);
% 
% appleSegments = imdilate(appleSegments,se);
% figure(2);
% hAxes1 = subplot(1,2,1);imagesc(currentImage{1}(:,:,1:3));axis image
% hAxes2 = subplot(1,2,2);imagesc(appleSegments);axis image;
% linkaxes([hAxes1,hAxes2]);
% 
% %% circle detetction
% figure(4);
% hAxes8 = subplot(1,2,1);imagesc(currentImage{1}(:,:,1:3));axis image
% hAxes9 = subplot(1,2,2);imagesc(currentImage{1}(:,:,1:3));axis image
% %  [centers, radii] = imfindcircles(appleSegments, [20 30], 'Sensitivity',0.99);
%  [centers, radii] = imfindcircles(appleSegments, [20], 'Sensitivity',0.99);
% linkaxes([hAxes8,hAxes9]);
% viscircles(centers,radii)
% toc




