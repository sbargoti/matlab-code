function pooledFeatures = cnnPool(poolDim, convolvedFeatures)
%cnnPool Pools the given convolved features
%
% Parameters:
%  poolDim - dimension of pooling region
%  convolvedFeatures - convolved features to pool (as given by cnnConvolve)
%                      convolvedFeatures(featureNum, imageNum, imageRow, imageCol)
%
% Returns:
%  pooledFeatures - matrix of pooled features in the form
%                   pooledFeatures(featureNum, imageNum, poolRow, poolCol)
%     

numImages = size(convolvedFeatures, 2);
numFeatures = size(convolvedFeatures, 1);
% convolvedDim = size(convolvedFeatures, 3);
convolvedDim1 = size(convolvedFeatures, 3);
convolvedDim2 = size(convolvedFeatures, 4);



% pooledFeatures = zeros(numFeatures, numImages, floor(convolvedDim / poolDim), floor(convolvedDim / poolDim));
pooledFeatures = zeros(numFeatures, numImages, floor(convolvedDim1 / poolDim), floor(convolvedDim2 / poolDim));



% -------------------- YOUR CODE HERE --------------------
% Instructions:
%   Now pool the convolved features in regions of poolDim x poolDim,
%   to obtain the 
%   numFeatures x numImages x (convolvedDim/poolDim) x (convolvedDim/poolDim) 
%   matrix pooledFeatures, such that
%   pooledFeatures(featureNum, imageNum, poolRow, poolCol) is the 
%   value of the featureNum feature for the imageNum image pooled over the
%   corresponding (poolRow, poolCol) pooling region 
%   (see http://ufldl/wiki/index.php/Pooling )
%   
%   Use mean pooling here.
% -------------------- YOUR CODE HERE --------------------

for i = 1:convolvedDim1 / poolDim
    for j = 1:convolvedDim2 / poolDim
        irange = (i-1)*poolDim + (1:poolDim);
        jrange = (j-1)*poolDim + (1:poolDim);
        pooledFeatures(:,:,i,j) = mean(mean(convolvedFeatures(:,:,irange ,jrange ),3),4);
%            pooledFeatures(:,:,i,j) = max(max(convolvedFeatures(:,:,irange ,jrange ),[],3),[],4);
     
    end
end



end

