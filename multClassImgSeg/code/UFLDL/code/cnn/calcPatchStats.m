% for scene classification, extract image statistics using learnt feature
% and perform pooling.  use "sceneClustering" function to perform kmean
% clustering based on the pooled features

function [pooledFeatures] = calcPatchStats(patches, patchSize, nPool)

% dbstop if error
% %%
% 
% currentPath = cd;
% rootPath = currentPath(1:(strfind(currentPath,'work')+4)); % to work/
% 
% rifaPath = [rootPath 'code\Projects\RIFA\'];
% addpath([rifaPath 'readBobGroundTruth'])
% 
% % unsupervised feature learning and deep learning
% ufldlPath = [rootPath 'code/UFLDL/code/'];
% addpath( [ufldlPath 'minFunc'])
% addpath( [ufldlPath 'numericalGradient'])
% % addpath( [ufldlPath 'sparseAutoencoder'])
% addpath( [ufldlPath 'linear_decoder'])
% addpath( [ufldlPath 'displayNetwork'])
% addpath( [ufldlPath 'softmax'])
% addpath( [ufldlPath 'stl'])
% addpath( [ufldlPath 'dataSet\stlSubset']) % mnist digit data set
% addpath( [ufldlPath 'cnn'])

%%

% patchesName = 'patches23053013';
% featuresName = 'cnnPooled23053013Features';
% patchSize = 32;
% nPool = 3;

% eval(['load ' patchesName]);

chRGBidx = 1:patchSize^2*3;
chNIRidx = patchSize^2*3+1:patchSize^2*4;
chTHMidx = patchSize^2*4+1:patchSize^2*5;

% data too big, random sample 1/10
% sampleIdx = randsample(length(patches),round(length(patches)/10));

% patchData = patches(chRGBidx,:)/255;
patchData = patches(chRGBidx,:);


patchData = reshape(patchData, [patchSize patchSize 3 size(patchData,2)]);

%%======================================================================
%% Initialization
%  Here we initialize some parameters used for the exercise.

[imDim1 imDim2 imDim3 nImgs] = size(patchData);
imageChannels = imDim3;     % number of channels (rgb, so 3)

patchDim = 8;          % patch dimension
% numPatches = 50000;    % number of patches

visibleSize = patchDim * patchDim * imageChannels;  % number of input units 
% outputSize = visibleSize;   % number of output units
hiddenSize = 400;           % number of hidden units 

epsilon = 0.1;	       % epsilon for ZCA whitening

poolDim = floor((imDim2 - patchDim + 1) / nPool); % nxn pooling



%%======================================================================

optTheta =  zeros(2*hiddenSize*visibleSize+hiddenSize+visibleSize, 1);
ZCAWhite =  zeros(visibleSize, visibleSize);
meanPatch = zeros(visibleSize, 1);

load STL10Features.mat
% --------------------------------------------------------------------

% Display and check to see that the features look good
W = reshape(optTheta(1:visibleSize * hiddenSize), hiddenSize, visibleSize);
b = optTheta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);

% displayColorNetwork( (W*ZCAWhite)');

%%======================================================================
%% Convolve and pool with the dataset

stepSize = 50;
assert(mod(hiddenSize, stepSize) == 0, 'stepSize should divide hiddenSize');

% pooledFeatures = zeros(hiddenSize, nImgs, ...
%     floor((imDim1 - patchDim + 1) / poolDim), ...
%     floor((imDim2 - patchDim + 1) / poolDim) );


pooledFeatures = zeros(hiddenSize, size(patchData,4), ...
    floor((imDim1 - patchDim + 1) / poolDim), ...
    floor((imDim2 - patchDim + 1) / poolDim) );

tic();
for convPart = 1:(hiddenSize / stepSize)
    
    featureStart = (convPart - 1) * stepSize + 1;
    featureEnd = convPart * stepSize;
    
    fprintf('Step %d: features %d to %d\n', convPart, featureStart, featureEnd);  
    Wt = W(featureStart:featureEnd, :);
    bt = b(featureStart:featureEnd);       


        % Pooling 
    fprintf('Convolving and pooling images\n');
    convolvedFeaturesThis = cnnConvolve(patchDim, stepSize, ...
        patchData, Wt, bt, ZCAWhite, meanPatch);
    pooledFeaturesThis = cnnPool(poolDim, convolvedFeaturesThis);
    pooledFeatures(featureStart:featureEnd, :, :, :) = pooledFeaturesThis;   
    toc();
    
    max(pooledFeatures(:))

    clear convolvedFeaturesThis pooledFeaturesThis;

end

% eval(['save ' featuresName ' pooledFeatures ']);

toc();

end




