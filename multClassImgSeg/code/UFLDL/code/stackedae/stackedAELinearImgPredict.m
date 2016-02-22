function [predIm, imFeatResp, hypothesis] = stackedAELinearImgPredict(theta, patchsize, hiddenSize, numClasses, netconfig, currentImage, ZCAWhite, meanPatch, resizeF, locationFeatFlag)
                                         
 
%% initialisation

[maxVal iMaxResizeF] = max(resizeF);
[maxImDim1 maxImDim2 maxImDim3] = size(currentImage{iMaxResizeF});
nScale = length(resizeF);

if locationFeatFlag == 0
    % We first extract the part which compute the softmax gradient
    softmaxTheta = reshape(theta(1:hiddenSize*numClasses*nScale), numClasses, hiddenSize*nScale);
    
    % Extract out the "stack"
    stack = params2stack(theta(hiddenSize*numClasses*nScale+1:end), netconfig);
    
    % nData = size(data,2);
elseif locationFeatFlag == 1
    % We first extract the part which compute the softmax gradient
    softmaxTheta = reshape(theta(1:(hiddenSize*nScale+2)*numClasses), numClasses, hiddenSize*nScale+2);
    % Extract out the "stack"
    stack = params2stack(theta((hiddenSize*nScale+2)*numClasses+1:end), netconfig);
%     nData = size(data,2);
end


%% image classifcation

% a{1} = data;
for d = 1:numel(stack)
%     a{d+1} = zeros(hiddenSize,nData,nScale);
    
    for iScale = 1:nScale
        
        W = stack{d}.w(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:);
        b = stack{d}.b(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:);
        hiddenSizeL = size(W,1);
        visibleSizeL = size(W,2);
        
        Xtmp = cnnConvolve(patchsize, hiddenSizeL, currentImage{iScale}, W, b, ZCAWhite(:,:,iScale), meanPatch(:,iScale));
        Xtmp = permute(Xtmp, [3 4 1 2]);
        
        Xresize = (imresize(Xtmp,1/resizeF(iScale)));
%         imageResizeBacktmp = (imresize(currentImage{iScale},1/resizeF(iScale),'nearest'));
        
        [imDim1 imDim2 imDim3] = size(Xresize);
        imDim1Diff = maxImDim1 - imDim1;
        imDim2Diff = maxImDim2 - imDim2;
        
        Xpad = padarray(Xresize, [ceil(imDim1Diff/2) ceil(imDim2Diff/2)],'replicate');
        
        X{iScale} = Xpad(1:maxImDim1,1:maxImDim2,:);
%         imageResizeBack{iScale} = imageResizeBacktmp(1:maxImDim1,1:maxImDim2,:);
        
        %     figure;imagesc(mean(X{iScale},3));
        %     figure;imagesc(imageResizeBack{iScale});
        
    end
end

imFeatResp = [];

for iScale = 1: nScale
    imFeatResp = (cat(3,imFeatResp,X{iScale} ));
end

[imDataDim1 imDataDim2 imDataDim3] = size(imFeatResp);
imFeatRespVect = zeros(imDataDim3, imDataDim1*imDataDim2);
for k = 1:imDataDim3
    imFeatResptmp = imFeatResp(:,:,k);
    imFeatRespVect(k,:) = imFeatResptmp(:);    
end

if locationFeatFlag == 1
    location = zeros(2, imDataDim1*imDataDim2);
    [location(1,:) location(2,:)] = meshgrid(imDataDim1,imDataDim2);
    location(1,:) = location(1,:)/imDataDim1;
    location(2,:) = location(2,:)/imDataDim2;
    imFeatRespVect = cat(1,imFeatRespVect, location);
end

h = p_y_given_x(imFeatRespVect, softmaxTheta);

[maxVal, argmax] = max(h);

pred = argmax;

predIm = reshape(pred, [imDataDim1 imDataDim2]);

hypothesis = reshape(h, [numClasses imDataDim1 imDataDim2]);



end


% You might find this useful
function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));
%     sigm = fi(1 ./ (1 + exp(double(-x))),1,10,15);
end

function sigmP = sigmoidPrime(x) % derivative of sigmoid function
sigmP = (x.*(1-x));
end

function hypothesis = p_y_given_x(data, theta) % softmax

numClass = size(theta,1);

thetaTx = theta*data;
% prevent overflowing when exp(thetaTx) is too huge
thetaTx = bsxfun(@minus, thetaTx, max(thetaTx, [], 1));
% thetaTx = fi(bsxfun(@minus, double(thetaTx), max(thetaTx, [], 1)),1,10,15);

expThetaTx = exp(thetaTx);
% expThetaTx = fi(exp(double(thetaTx)),1,10,15);

normF = sum(expThetaTx,1);

hypothesis = expThetaTx./repmat(normF, [numClass 1]);
% hypothesis = fi(double(expThetaTx)./repmat(double(normF), [numClass 1]),1,10,15);
end
