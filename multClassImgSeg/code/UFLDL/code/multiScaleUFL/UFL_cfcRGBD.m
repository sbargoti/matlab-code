function [theta, meanPatch ,ZCAWhite] = UFL_cfcRGBD(trainData, invalidmask, nband, resizeF, patchsize, inputSize, hiddenSizeL1, sparsityParam, lambda, beta, epsilon, numPatches)

%%  initialisation
% numpatches = 100000;
numpatches = numPatches;
fprintf('Image Rescale Factor: %3.3f\n', resizeF);
fprintf('Patch Size: %3.3f\n', patchsize);
fprintf('Number of Hidden Nodes: %3.3f\n', hiddenSizeL1);



%% 1: Extract Training Patches for unsupervised learning
[dim1 dim2 dim3 numImages] = size(trainData);
if resizeF ~= 1
%     trainDataResize = zeros(round(dim1*resizeF), round(dim2*resizeF), dim3, numImages);
%     invalidmaskResize = zeros(round(dim1*resizeF), round(dim2*resizeF), numImages);
%     
    trainDataResize = zeros(ceil(dim1*resizeF), ceil(dim2*resizeF), dim3, numImages);
    invalidmaskResize = zeros(ceil(dim1*resizeF), ceil(dim2*resizeF), numImages);
    for iImage = 1:numImages
%         trainDataResize(:,:,:,iImage) = imresize(trainData(:,:,:,iImage), resizeF, 'nearest');
        trainDataResize(:,:,:,iImage) = imresize(trainData(:,:,:,iImage), resizeF);
        invalidmaskResize(:,:,iImage) = imresize(invalidmask(:,:,iImage), resizeF);   
    end
    trainData = trainDataResize;
    invalidmask = invalidmaskResize;
    clear trainDataResize invalidmaskResize
end

patches = sampleRGBDIMAGES(trainData, invalidmask, nband, patchsize, numPatches);
% patches = sampleColourIMAGES(trainData, patchsize, numPatches);

% figure(1)
patches = patches(:, randperm(numpatches)); % shuffle the patches out of order
% displayRGBDNetwork(patches(:, 1:100));
% 
% disp('ZCA whitening')

% if plotFlag == 1
%     figure;title('Patches');
%     if dataType == 1     % 1: Grey
%         display_network( patches(:, 1:100));
%     elseif dataType == 2 % 2: Depth
%         display_network( patches(:, 1:100));
%     elseif dataType == 3 % 3: RGB
%         displayColorNetwork( patches(:, 1:100));
%     elseif dataType == 4 % 4: RGBD
%         displayRGBDNetwork( patches(:, 1:100));
%     end
% end

% 
[patches, meanPatch ,ZCAWhite] = ZCAwhitening(patches, epsilon);
% 
% figure(2)
% displayRGBDNetwork(patches(:, 1:100));

% save VOCpatches patches
% load VOCpatches

%% 2.1: Unsupervied Feature Learning (1st layer, using linear decoder)
% load VOCpatches

disp(' Unsupervied Feature Learning ')

visibleSize = inputSize;
hiddenSize = hiddenSizeL1;
theta = initializeParameters(hiddenSize, visibleSize);

% tic;
[sparseAutoencoderLinearModel] = sparseAutoencoderLinearTrain(visibleSize, hiddenSize, ...
    lambda, sparsityParam, beta, patches, theta);

% beta = 0;
% noiseLevel = 0.3;
% [sparseAutoencoderLinearModel] = denoiseAutoencoderLinearTrain(visibleSize, hiddenSize, ...
%     lambda, sparsityParam, beta, patches, noiseLevel, theta);
% toc                                         
                    
sae1OptTheta =  sparseAutoencoderLinearModel.opttheta;    

% fprintf('Saving learned features and preprocessing matrices...\n');                          
% save('VOCFeatures.mat', 'sae1OptTheta', 'ZCAWhite', 'meanPatch');
% fprintf('Saved\n');    

% display the learned weights
% load VOCFeatures
visibleSize = inputSize;
hiddenSize = hiddenSizeL1;
W = gather(reshape(sae1OptTheta(1:visibleSize * hiddenSize), hiddenSize, visibleSize));
b = gather(sae1OptTheta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize));
% figure(3);title('learnt W');
% displayRGBDNetwork( (W*ZCAWhite)');


theta = sae1OptTheta;
% visibleSize = inputSize;
% hiddenSize = hiddenSizeL1;
% data = patches;
% [activation] = feedForwardAutoencoder(theta, hiddenSize, visibleSize, data);
% sae1Features = activation;


% 

end