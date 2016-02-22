function [centroids, meanPatch ,ZCAWhite] = UFL_cfcRGBD(trainData, invalidmask, nband, resizeF, patchsize, inputSize, hiddenSizeL1, sparsityParam, lambda, beta, epsilon, numPatches)

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
    invalidmaskResize = zeros(round(dim1*resizeF), round(dim2*resizeF), numImages);
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
% [patches, meanPatch ,ZCAWhite] = ZCAwhitening(patches, epsilon);


%% let's run kmeans from Coates!!


% rfSize = 6;
numCentroids=1600;
whitening=true;

patches = patches';

% normalize for contrast
patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
% patches =  bsxfun(@minus, patches, mean(patches,2)); % what UFLDL site said std normalisation isn't necessary


% whiten
if (whitening)
  C = cov(patches); %[1 1]
  M = mean(patches);%[1 108]
  [V,D] = eig(C);   % V:[108 108] D:[108 108]
  P = V * diag(sqrt(1./(diag(D) + 0.1))) * V'; %P:[108 108]
  patches = bsxfun(@minus, patches, M) * P;
end

% run K-means
centroids = run_kmeans(patches, numCentroids, 50); %[1600 108]
show_centroids(centroids, patchsize); drawnow;

meanPatch = M;
ZCAWhite = P;

end