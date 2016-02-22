%% CS294A/CS294W Linear Decoder Exercise

%  Instructions
%  ------------
% 
%  This file contains code that helps you get started on the
%  linear decoder exericse. For this exercise, you will only need to modify
%  the code in sparseAutoencoderLinearCost.m. You will not need to modify
%  any code in this file.

%% Dependencies
% rootPath = 'D:\Work\code\UFLDL\code\';
currentPath = cd;
rootPath = currentPath(1:(strfind(currentPath,'work')+4)); % to work/
ufldlPath = [rootPath 'code/UFLDL/code/'];
addpath( [ufldlPath 'minFunc'])
addpath( [ufldlPath 'numericalGradient'])
addpath( [ufldlPath 'sparseAutoencoder'])
addpath( [ufldlPath 'displayNetwork'])
% addpath( [rootPath 'softmax'])
% addpath( [rootPath 'stl'])
addpath( [ufldlPath 'dataSet\stl10_patches_100k']) % 
addpath( [ufldlPath 'dataSet']) % small fast test data set and load image functions

%%======================================================================
%% STEP 0: Initialization
%  Here we initialize some parameters used for the exercise.

imageChannels = 3;     % number of channels (rgb, so 3)

patchDim   = 8;          % patch dimension
numPatches = 100000;   % number of patches

visibleSize = patchDim * patchDim * imageChannels;  % number of input units 
outputSize  = visibleSize;   % number of output units
hiddenSize  = 400;           % number of hidden units 
% hiddenSize  = 1000;           % number of hidden units 


sparsityParam = 0.035; % desired average activation of the hidden units.
lambda = 3e-3;         % weight decay parameter       
beta = 5;              % weight of sparsity penalty term       

epsilon = 0.1;	       % epsilon for ZCA whitening

%%======================================================================
%% STEP 1: Create and modify sparseAutoencoderLinearCost.m to use a linear decoder,
%          and check gradients
%  You should copy sparseAutoencoderCost.m from your earlier exercise 
%  and rename it to sparseAutoencoderLinearCost.m. 
%  Then you need to rename the function from sparseAutoencoderCost to
%  sparseAutoencoderLinearCost, and modify it so that the sparse autoencoder
%  uses a linear decoder instead. Once that is done, you should check 
% your gradients to verify that they are correct.

% NOTE: Modify sparseAutoencoderCost first!

% To speed up gradient checking, we will use a reduced network and some
% dummy patches

debugHiddenSize = 5;
debugvisibleSize = 8;
patches = rand([8 10]);
theta = initializeParameters(debugHiddenSize, debugvisibleSize); 

[cost, grad] = sparseAutoencoderLinearCost(theta, debugvisibleSize, debugHiddenSize, ...
                                           lambda, sparsityParam, beta, ...
                                           patches);

% Check gradients
numGrad = computeNumericalGradient( @(x) sparseAutoencoderLinearCost(x, debugvisibleSize, debugHiddenSize, ...
                                                  lambda, sparsityParam, beta, ...
                                                  patches), theta);

% Use this to visually compare the gradients side by side
disp([numGrad grad]); 

diff = norm(numGrad-grad)/norm(numGrad+grad);
% Should be small. In our implementation, these values are usually less than 1e-9.
disp(diff); 

assert(diff < 1e-9, 'Difference too large. Check your gradient computation again');

% NOTE: Once your gradients check out, you should run step 0 again to
%       reinitialize the parameters
%}

%%======================================================================
%% STEP 2: Learn features on small patches
%  In this step, you will use your sparse autoencoder (which now uses a 
%  linear decoder) to learn features on small patches sampled from related
%  images.

%% STEP 2a: Load patches
%  In this step, we load 100k patches sampled from the STL10 dataset and
%  visualize them. Note that these patches have been scaled to [0,1]

load stlSampledPatches.mat

displayColorNetwork(patches(:, 1:100));

%% STEP 2b: Apply preprocessing
%  In this sub-step, we preprocess the sampled patches, in particular, 
%  ZCA whitening them. 
% 
%  In a later exercise on convolution and pooling, you will need to replicate 
%  exactly the preprocessing steps you apply to these patches before 
%  using the autoencoder to learn features on them. Hence, we will save the
%  ZCA whitening and mean image matrices together with the learned features
%  later on.


% % % normalize for contrast
% % patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
% % 
% % 
% %   meanPatch = mean(patches);
% % sigma = patches * patches' / numPatches;
% % [u, s, v] = svd(sigma);
% %   ZCAWhite = u * diag(sqrt(1./(diag(s) + 0.1))) * u';
% %   patches = ZCAWhite* bsxfun(@minus, patches, M);

  % % from Coates
% % %   % normalize for contrast
% % % patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
% % % 
% % % % whiten
% % % if (whitening)
% % %   C = cov(patches);
% % %   M = mean(patches);
% % %   [V,D] = eig(C);
% % %   P = V * diag(sqrt(1./(diag(D) + 0.1))) * V';
% % %   patches = bsxfun(@minus, patches, M) * P;
% % % end
  

% Subtract mean patch (hence zeroing the mean of the patches)
meanPatch = mean(patches, 2);  
patches = bsxfun(@minus, patches, meanPatch);

% % % normalise to 1 std
% % stdPatch = std(patches,[],2);
% % patches = bsxfun(@rdivide, patches, stdPatch);

% Apply ZCA whitening
sigma = patches * patches' / numPatches;
[u, s, v] = svd(sigma);
ZCAWhite = u * diag(1 ./ sqrt(diag(s) + epsilon)) * u';
patches = ZCAWhite * patches;

% % % test to normalise correlatino to 1 (Lecun told me so)
% patches = patches/std(patches(:));

displayColorNetwork(patches(:, 1:100));

%%
 figure;displayColorNetwork( (patches(:,1:100)));

%% STEP 2c: Learn features
%  You will now use your sparse autoencoder (with linear decoder) to learn
%  features on the preprocessed patches. This should take around 45 minutes.

theta = initializeParameters(hiddenSize, visibleSize);
% theta = optTheta;

[sparseAutoencoderLinearModel] = sparseAutoencoderLinearTrain(visibleSize, hiddenSize, ...
                                             lambda, sparsityParam, beta, patches, theta);
                    
optTheta =  sparseAutoencoderLinearModel.opttheta;                                    

% % options = struct;
% % options.Method = 'lbfgs'; 
% % options.maxIter = 400;
% % options.display = 'on';
% % 
% % [optTheta, cost] = minFunc( @(p) sparseAutoencoderLinearCost(p, ...
% %                                    visibleSize, hiddenSize, ...
% %                                    lambda, sparsityParam, ...
% %                                    beta, patches), ...
% %                               theta, options);

% Save the learned features and the preprocessing matrices for use in 
% the later exercise on convolution and pooling
fprintf('Saving learned features and preprocessing matrices...\n');                          
save('STL10FeaturesTest400MZ.mat', 'optTheta', 'ZCAWhite', 'meanPatch');
fprintf('Saved\n');

%% STEP 2d: Visualize learned features

W = reshape(optTheta(1:visibleSize * hiddenSize), hiddenSize, visibleSize);
b = optTheta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);
figure;displayColorNetwork( (W*ZCAWhite)');
% displayColorNetwork( (W)');

%% For mark

W_multi = reshape(W, hiddenSize, patchDim, patchDim,imageChannels);
save W_multi W_multi
