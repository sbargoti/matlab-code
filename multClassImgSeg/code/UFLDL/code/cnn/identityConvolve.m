function convolvedFeatures = identityConvolve(patchDim, numFeatures, images, W, b, ZCAWhite, meanPatch, CNNmethod)
%cnnConvolve Returns the convolution of the features given by W and b with
%the given images
%
% Parameters:
%  patchDim - patch (feature) dimension
%  numFeatures - number of features
%  images - large images to convolve with, matrix in the form
%           images(r, c, channel, image number)
%  W, b - W, b for features from the sparse autoencoder
%  ZCAWhite, meanPatch - ZCAWhitening and meanPatch matrices used for
%                        preprocessing
%
% Returns:
%  convolvedFeatures - matrix of convolved features in the form
%                      convolvedFeatures(featureNum, imageNum, imageRow, imageCol)

if nargin < 8
    CNNmethod = 'valid';
end

numImages = size(images, 4);
% imageDim = size(images, 1);
imDim1 = size(images, 1);
imDim2 = size(images, 2);
imageChannels = size(images, 3);


% Instructions:
%   Convolve every feature with every large image here to produce the 
%   numFeatures x numImages x (imageDim - patchDim + 1) x (imageDim - patchDim + 1) 
%   matrix convolvedFeatures, such that 
%   convolvedFeatures(featureNum, imageNum, imageRow, imageCol) is the
%   value of the convolved featureNum feature for the imageNum image over
%   the region (imageRow, imageCol) to (imageRow + patchDim - 1, imageCol + patchDim - 1)
%
% Expected running times: 
%   Convolving with 100 images should take less than 3 minutes 
%   Convolving with 5000 images should take around an hour
%   (So to save time when testing, you should convolve with less images, as
%   described earlier)

% -------------------- YOUR CODE HERE --------------------
% Precompute the matrices that will be used during the convolution. Recall
% that you need to take into account the whitening and mean subtraction
% steps


% Subtract mean patch (hence zeroing the mean of the patches)
% images = bsxfun(@minus, images, meanPatch);

if strcmp(CNNmethod,'valid')
convolvedFeatures = zeros(numFeatures, numImages, imDim1 - patchDim + 1, imDim2 - patchDim + 1);
elseif strcmp(CNNmethod,'same')
convolvedFeatures = zeros(numFeatures, numImages, imDim1, imDim2 );
end


% Apply ZCA whitening


Wprep = W*ZCAWhite;
bprep = b - W*ZCAWhite*meanPatch;
% --------------------------------------------------------

% convolvedFeatures = zeros(numFeatures, numImages, imDim1 - patchDim + 1, imDim2 - patchDim + 1);
for imageNum = 1:numImages
  for featureNum = 1:numFeatures

    % convolution of image with feature matrix for each channel
    if strcmp(CNNmethod,'valid')
        convolvedImage = zeros(imDim1 - patchDim + 1, imDim2 - patchDim + 1);
    elseif strcmp(CNNmethod,'same') 
        convolvedImage = zeros(imDim1, imDim2);
    end
    currentFeature = reshape(Wprep(featureNum,:),[patchDim patchDim 3]);
    for channel = 1:3

      % Obtain the feature (patchDim x patchDim) needed during the convolution
      
      feature = currentFeature(:,:,channel);      
      

      % Flip the feature matrix because of the definition of convolution, as explained later
      feature = flipud(fliplr(squeeze(feature)));
      
      % Obtain the image
      im = squeeze(images(:, :, channel, imageNum));

      % Convolve "feature" with "im", adding the result to convolvedImage
      % be sure to do a 'valid' convolution
      % ---- YOUR CODE HERE ----

      
      % merge the channels
      convolvedImage = conv2(im,feature, CNNmethod)+convolvedImage;
      
      
      % ------------------------

    end
    
    % Subtract the bias unit (correcting for the mean subtraction as well)
    % Then, apply the sigmoid function to get the hidden activation
    % ---- YOUR CODE HERE ----

    convolvedImage = convolvedImage + bprep(featureNum);
    
%     convolvedImage = sigmoid(convolvedImage);
    
    % ------------------------
    
    % The convolved feature is the sum of the convolved values for all channels
    convolvedFeatures(featureNum, imageNum, :, :) = convolvedImage;
%     featureNum
  end
    if rem(imageNum,10) == 0
        fprintf('cnnConvolve: Convolve Patch %i/%i \n', imageNum,numImages);
    end  
end


end



function sigm = sigmoid(x)
  
    sigm = 1 ./ (1 + exp(-x));
end


