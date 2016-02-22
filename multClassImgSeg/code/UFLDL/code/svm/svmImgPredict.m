function [predIm, imFeatResp, hypothesis] = svmImgPredict(theta, svmTheta, patchsize, hiddenSize, numClasses, netconfig, currentImage, ZCAWhite, meanPatch, resizeF, locationFeatFlag)

% stackedAEPredict: Takes a trained theta and a test data set,
% and returns the predicted labels for each example.

% theta: trained weights from the autoencoder
% visibleSize: the number of input units
% hiddenSize:  the number of hidden units *at the 2nd layer*
% numClasses:  the number of categories
% data: Our matrix containing the training data as columns.  So, data(:,i) is the i-th training example.

% Your code should produce the prediction matrix
% pred, where pred(i) is argmax_c P(y(c) | x(i)).

%% Unroll theta parameter

[maxVal iMaxResizeF] = max(resizeF);
[maxImDim1 maxImDim2 maxImDim3] = size(currentImage{iMaxResizeF});
nScale = length(resizeF);
finetuningFlag = 0;

% if finetuningFlag == 1
    
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
    
% elseif finetuningFlag == 0
    sae1OptTheta = theta;
    [trash visibleSize] = size(stack{1}.w);

% end

%% ---------- YOUR CODE HERE --------------------------------------


% a{1} = data;
for d = 1:numel(stack)
    %     a{d+1} = zeros(hiddenSize,nData,nScale);
    
    for iScale = 1:nScale
        
        if finetuningFlag == 1
            
            W = stack{d}.w(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:);
            b = stack{d}.b(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:);
            
            
        elseif finetuningFlag == 0
            
            W = reshape(sae1OptTheta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
            b = sae1OptTheta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize)';
            
        end
        
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

% h = p_y_given_x(imFeatRespVect, softmaxTheta);
%
% [maxVal, argmax] = max(h);
%
% pred = argmax;
testXC = imFeatRespVect';
% 
% testXCs = bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd);
% testXCs = [testXCs, ones(size(testXC,1),1)];
testXCs = [testXC, ones(size(testXC,1),1)];


h = testXCs*svmTheta;

pred = pred_svm(testXCs, svmTheta);

predIm = reshape(pred, [imDataDim1 imDataDim2]);

hypothesis = reshape(h, [numClasses imDataDim1 imDataDim2]);


% -----------------------------------------------------------

end


% You might find this useful
function sigm = sigmoid(x)
sigm = 1 ./ (1 + exp(-x));
end

function sigmP = sigmoidPrime(x) % derivative of sigmoid function
sigmP = (x.*(1-x));
end

function hypothesis = p_y_given_x(data, theta) % softmax

numClass = size(theta,1);

thetaTx = theta*data;
% prevent overflowing when exp(thetaTx) is too huge
thetaTx = bsxfun(@minus, thetaTx, max(thetaTx, [], 1));

expThetaTx = exp(thetaTx);

normF = sum(expThetaTx,1);

hypothesis = expThetaTx./repmat(normF, [numClass 1]);

end
