% function [patches ] = sampleIMAGES(patchsize)
% this is the same as sampleRGBDIMAGES, but does it per frame for large
% image set
% function patches = sampleRGBDIMAGESperFrame(images, invalidmask, nband, patchsize, numPatches)
function patches = sampleRGBDIMAGESperFrame(imgList, dataPath, resizeF, nband, patchsize, numPatches)

disp(' Sample RGBD image patches ')



% IMAGES = double(images);
numpatches = numPatches;
% dont need this cuz the data dimension is alway 4D
% if nband == 1
%     [dim1 dim2 numImage] = size(IMAGES);
% elseif nband >1
%     [dim1 dim2 dim3 numImage] = size(IMAGES);
% end

numImage = size(imgList,1);

patchesPerImage = ceil(numpatches/numImage);
numPatches = patchesPerImage*numImage;

% patches = zeros(patchsize*patchsize*dim3, numpatches);
patches = zeros(patchsize*patchsize*nband, numpatches);

invalidFlag = 1;
tic;
for iImage = 1:numImage
    currentImage = im2double(imread([dataPath imgList(iImage).name]));
    currentImage = imresize(currentImage,resizeF);
    [dim1 dim2 dim3] = size(currentImage);
% for i=1:numpatches
for i=1:patchesPerImage

          
    % valid image range
    dim1Lim = dim1 - patchsize;
    dim2Lim = dim2 - patchsize;   
    
    while 1
        coord1 = ceil(rand*dim1Lim);   % randomly start coordinate 1
        coord2 = ceil(rand*dim2Lim);   % randomly start coordinate 2
        coord1END = coord1 + patchsize -1;
        coord2END = coord2 + patchsize -1;
%         imageNo = ceil(rand*numImage);% randomly select image
        
%         invalidmaskPatch = invalidmask(coord1:coord1END, ...
%             coord2:coord2END,imageNo);  
        
        imagePatch = currentImage(coord1:coord1END, ...
                    coord2:coord2END,1:nband);       
        
%         invalidFlag = sum(invalidmaskPatch(:));

        
%         if (invalidFlag == 0)&&(entropy(imagePatch)>(4/nband))
%         if (invalidFlag == 0)&&(entropy(imagePatch)>(1/nband)) % grey band needs a lot lower entropy or it samples really slow
%         if (invalidFlag == 0)&&(entropy(imagePatch)>2) % grey band needs a lot lower entropy or it samples really slow
        if (entropy(imagePatch)>2) % grey band needs a lot lower entropy or it samples really slow


            break
        end
    end  
    
    patches(:,(i+(iImage-1)* patchesPerImage)) = imagePatch(:);    
   
    if toc > 3
        fprintf('Patch: %i/%i, Image: %i/%i\n',i,patchesPerImage, iImage, numImage);
        tic;
    end
end

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
