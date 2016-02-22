% function [patches ] = sampleIMAGES(patchsize)
function patches = sampleColourIMAGES(images, patchsize, numPatches)


% sampleIMAGES
% Returns 10000 patches for training

% load IMAGES;    % load images from disk
% images = images.IMAGES;
IMAGES = double(images);


% patchsize = 12;  % we'll use 8x8 patches 
% numpatches = 10000;
numpatches = numPatches;


% Initialize patches with zeros.  Your code will fill in this matrix--one
% column per patch, 10000 columns. 
[dim1 dim2 dim3 numImage] = size(IMAGES);

patches = zeros(patchsize*patchsize*dim3, numpatches);
% features = zeros(patchsize*patchsize + 2, numpatches);

%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Fill in the variable called "patches" using data 
%  from IMAGES.  
%  
%  IMAGES is a 3D array containing 10 images
%  For instance, IMAGES(:,:,6) is a 512x512 array containing the 6th image,
%  and you can type "imagesc(IMAGES(:,:,6)), colormap gray;" to visualize
%  it. (The contrast on these images look a bit off because they have
%  been preprocessed using using "whitening."  See the lecture notes for
%  more details.) As a second example, IMAGES(21:30,21:30,1) is an image
%  patch corresponding to the pixels in the block (21,21) to (30,30) of
%  Image 1

for i=1:numpatches
          
    % valid image range
    dim1Lim = dim1 - patchsize;
    dim2Lim = dim2 - patchsize;   
    
    coord1 = ceil(rand*dim1Lim);   % randomly start coordinate 1
    coord2 = ceil(rand*dim2Lim);   % randomly start coordinate 2
    coord1END = coord1 + patchsize -1;
    coord2END = coord2 + patchsize -1;
    imageNo = ceil(rand*numImage);% randomly select image 
    
    imagePatch = IMAGES(coord1:coord1END, ...
                    coord2:coord2END,:, ...
                    imageNo);
    
    patches(:,i) = imagePatch(:);    
   
end

%% ---------------------------------------------------------------
% For the autoencoder to work well we need to normalize the data
% Specifically, since the output of the network is bounded between [0,1]
% (due to the sigmoid activation function), we have to make sure 
% the range of pixel values is also bounded between [0,1]
% patches = normalizeData(patches);

% normalize for contrast
% patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));


end


%% ---------------------------------------------------------------
function patches = normalizeData(patches)

% Squash data to [0.1, 0.9] since we use sigmoid as the activation
% function in the output layer

% Remove DC (mean of images). 
patches = bsxfun(@minus, patches, mean(patches));

% Truncate to +/-3 standard deviations and scale to -1 to 1
pstd = 3 * std(patches(:));
patches = max(min(patches, pstd), -pstd) / pstd;

% Rescale from [-1,1] to [0.1,0.9]
patches = (patches + 1) * 0.4 + 0.1;

end
