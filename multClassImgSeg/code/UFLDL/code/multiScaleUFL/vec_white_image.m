function [imageV imageVW] = vec_white_image(image, meanPatch, ZCAWhite)

[dim1 dim2 dim3 dim4] = size(image);
imageV =  zeros(dim1*dim2*dim3 , dim4);
imageVW = zeros(dim1*dim2*dim3 , dim4); % whiten

tic;
for i = 1:dim4
    imageTemp = image(:,:,:,i);
    imageV(:,i) = imageTemp(:);

    if toc > 1
        fprintf('%i/%i \n', i, dim4);
        tic;
    end
end

% patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,1)), sqrt(var(patches,[],1)+10));
% imageV =  bsxfun(@minus, imageV, mean(imageV,1)); % this somehow makes the result worse


% imageVW = imageV - meanPatch;
imageV = bsxfun(@minus, imageV, meanPatch);
imageVW = ZCAWhite * imageV;