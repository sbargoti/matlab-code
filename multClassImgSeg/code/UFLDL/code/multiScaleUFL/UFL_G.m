function [theta, meanPatch ,ZCAWhite] = UFL_G(trainData, resizeF, patchsize, inputSize, hiddenSizeL1, sparsityParam, lambda, beta, epsilon, numPatches)

%%  initialisation
% numpatches = 100000;
numpatches = numPatches;
fprintf('Image Rescale Factor: %3.3f\n', resizeF);
fprintf('Patch Size: %3.3f\n', patchsize);
fprintf('Number of Hidden Nodes: %3.3f\n', hiddenSizeL1);



%% 1: Extract Training Patches for unsupervised learning
[dim1 dim2 dim3 numImages] = size(trainData);
if resizeF ~= 1
    trainDataResize = zeros(round(dim1*resizeF), round(dim2*resizeF), dim3, numImages);
    for iImage = 1:numImages
%         trainDataResize(:,:,:,iImage) = imresize(trainData(:,:,:,iImage), resizeF, 'nearest');
        trainDataResize(:,:,:,iImage) = imresize(trainData(:,:,:,iImage), resizeF);
    end
    trainData = trainDataResize;
    clear trainDataResize
end

patches = sampleIMAGES(trainData, patchsize, numPatches);
% patches = sampleIMAGESVOC(resizeF, patchsize, numpatches);
% figure(1)
patches = patches(:, randperm(numpatches)); % shuffle the patches out of order
% display_network(patches(:, 1:100));
% 
% disp('ZCA whitening')
% 
[patches, meanPatch ,ZCAWhite] = ZCAwhitening(patches, epsilon);
% 
% figure(2)
% display_network(patches(:, 1:100));


%% 2.1: Unsupervied Feature Learning (1st layer, using linear decoder)
% load VOCpatches

disp(' Unsupervied Feature Learning ')

visibleSize = inputSize;
hiddenSize = hiddenSizeL1;
theta = initializeParameters(hiddenSize, visibleSize);

% tic;
[sparseAutoencoderLinearModel] = sparseAutoencoderLinearTrain(visibleSize, hiddenSize, ...
                                             lambda, sparsityParam, beta, patches, theta);
% toc                                         
                    
sae1OptTheta =  sparseAutoencoderLinearModel.opttheta;    

% fprintf('Saving learned features and preprocessing matrices...\n');                          
% save('VOCFeatures.mat', 'sae1OptTheta', 'ZCAWhite', 'meanPatch');
% fprintf('Saved\n');    

% display the learned weights
% load VOCFeatures
% visibleSize = inputSize;
% hiddenSize = hiddenSizeL1;
% W = gather(reshape(sae1OptTheta(1:visibleSize * hiddenSize), hiddenSize, visibleSize));
% b = gather(sae1OptTheta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize));
% figure(3);title('learnt W');
% display_network( (W*ZCAWhite)');


theta = sae1OptTheta;
% visibleSize = inputSize;
% hiddenSize = hiddenSizeL1;
% data = patches;
% [activation] = feedForwardAutoencoder(theta, hiddenSize, visibleSize, data);
% sae1Features = activation;

%% 2.2: Unsupervied Feature Learning (2nd layer, using decoder)
% 
% visibleSize = hiddenSizeL1;
% hiddenSize = hiddenSizeL2;
% sae2Theta = initializeParameters(hiddenSize, visibleSize);
% data = sae1Features;
% theta = sae2Theta;
% sparsityParam = 0.1;   % desired average activation of the hidden units.
% lambda = 3e-3;         % weight decay parameter       
% beta = 3;              % weight of sparsity penalty term       
% [sparseAutoencoderModel2] = sparseAutoencoderTrain(visibleSize, hiddenSize, ...
%                                              lambda, sparsityParam, beta, data, theta);
% 
% sae2OptTheta =  sparseAutoencoderModel2.opttheta;    
% 
% theta = sae2OptTheta;
% hiddenSize = hiddenSizeL2;
% visibleSize = hiddenSizeL1;
% data = sae1Features;
% 
% [activation] = feedForwardAutoencoder(theta, hiddenSize, visibleSize, data);
% sae2Features = activation;
% % notes: stupidly the sae2Features is a matrix full identical number of
% % 3.5 when using the same number hidden and visible nodes 
% save sparseAutoencoderModel2 sparseAutoencoderModel2

% %% 2.3: Unsupervied Feature Learning (3nd layer, using decoder)
% 
% visibleSize = hiddenSizeL2;
% hiddenSize = hiddenSizeL3;
% sae3Theta = initializeParameters(hiddenSize, visibleSize);
% data = sae2Features;
% theta = sae3Theta;
% 
% [sparseAutoencoderModel3] = sparseAutoencoderTrain(visibleSize, hiddenSize, ...
%                                              lambda, sparsityParam, beta, data, theta);
% 
% 
% sae3OptTheta =  sparseAutoencoderModel3.opttheta;    
% 
% theta = sae3OptTheta;
% hiddenSize = hiddenSizeL3;
% visibleSize = hiddenSizeL2;
% data = sae2Features;
% 
% [activation] = feedForwardAutoencoder(theta, hiddenSize, visibleSize, data);
% sae3Features = activation;
% 
% save sparseAutoencoderModel3 sparseAutoencoderModel3
% 

end