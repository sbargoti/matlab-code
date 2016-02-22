function [ cost, grad ] = stackedAELinearCost(theta, inputSize, hiddenSize, ...
                                              numClasses, netconfig, ...
                                              lambda, data, locations, labels, nScale, locationFeatFlag)
                                         
% stackedAECost: Takes a trained softmaxTheta and a training data set with labels,
% and returns cost and gradient using a stacked autoencoder model. Used for
% finetuning.
                                         
% theta: trained weights from the autoencoder
% visibleSize: the number of input units
% hiddenSize:  the number of hidden units *at the 2nd layer*
% numClasses:  the number of categories
% netconfig:   the network configuration of the stack
% lambda:      the weight regularization penalty
% data: Our matrix containing the training data as columns.  So, data(:,i) is the i-th training example. 
% labels: A vector containing labels, where labels(i) is the label for the
% i-th training example

% locationFeatFlag = 1; % if it's on use location

%% Unroll softmaxTheta parameter


if locationFeatFlag == 0
    % We first extract the part which compute the softmax gradient
    softmaxTheta = reshape(theta(1:hiddenSize*numClasses*nScale), numClasses, hiddenSize*nScale);
    % Extract out the "stack"
    stack = params2stack(theta(hiddenSize*numClasses*nScale+1:end), netconfig);
elseif locationFeatFlag == 1
    % We first extract the part which compute the softmax gradient
    softmaxTheta = reshape(theta(1:(hiddenSize*nScale+2)*numClasses), numClasses, hiddenSize*nScale+2);
    % Extract out the "stack"
    stack = params2stack(theta((hiddenSize*nScale+2)*numClasses+1:end), netconfig);
end

% You will need to compute the following gradients
softmaxThetaGrad = zeros(size(softmaxTheta));
stackgrad = cell(size(stack));
for d = 1:numel(stack)
    stackgrad{d}.w = zeros(size(stack{d}.w));
    stackgrad{d}.b = zeros(size(stack{d}.b));
end

cost = 0; % You need to compute this

% You might find these variables useful
M = size(data, 2);
groundTruth = full(sparse(labels, 1:M, 1)); % if label doesn't contain all possible labels it might crash

nData = size(data,2);


%% --------------------------- YOUR CODE HERE -----------------------------
%  Instructions: Compute the cost function and gradient vector for 
%                the stacked autoencoder.
%
%                You are given a stack variable which is a cell-array of
%                the weights and biases for every layer. In particular, you
%                can refer to the weights of Layer d, using stack{d}.w and
%                the biases using stack{d}.b . To get the total number of
%                layers, you can use numel(stack).
%
%                The last layer of the network is connected to the softmax
%                classification layer, softmaxTheta.
%
%                You should compute the gradients for the softmaxTheta,
%                storing that in softmaxThetaGrad. Similarly, you should
%                compute the gradients for each layer in the stack, storing
%                the gradients in stackgrad{d}.w and stackgrad{d}.b
%                Note that the size of the matrices in stackgrad should
%                match exactly that of the size of the matrices in stack.
%

% perform feedforward to get activations

%% forwardpass


a{1} = data;
for d = 1:numel(stack)
    a{d+1} = zeros(hiddenSize,nData,nScale);
    
    for iScale = 1:nScale
        
        wTmp = stack{d}.w(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:);
        bTmp = stack{d}.b(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:);
        saeLOptTheta = [ wTmp(:) ; wTmp(:) ;bTmp(:) ; bTmp(:) ];
        hiddenSizeL = size(wTmp,1);
        visibleSizeL = size(wTmp,2);  
                
        a{d+1}(:,:,iScale) = feedForwardAutoencoder(saeLOptTheta, hiddenSizeL, ...
            visibleSizeL, a{d}(:,:,iScale));      

    end
end
% sae1OptTheta = [ stack{1}.w(:) ; stack{1}.w(:) ;stack{1}.b(:) ; stack{1}.b(:)  ];
% hiddenSizeL1 = size(stack{1}.w,1);
% a1 = data;
% [a2] = feedForwardAutoencoder(sae1OptTheta, hiddenSizeL1, ...
%     inputSize, a1);
% 
% sae2OptTheta = [ stack{2}.w(:) ; stack{2}.w(:) ;stack{2}.b(:) ; stack{2}.b(:) ];
% hiddenSizeL2 = size(stack{2}.w,1);
% [a3] = feedForwardAutoencoder(sae2OptTheta, hiddenSizeL2, ...
%     hiddenSizeL1, a2);

%% Back Propagation

% NOTE: at this stage, the input to the softmax classfier needs to be joint
% together (hiddenSize*nScale)instead of doing it scale by scale (hiddenSize, nScale)
% dels (softmax layer)
numLayers = numel(stack)+1;
% delJ = zeros(hiddenSize,nData,nScale);
% delSoftmax = zeros(hiddenSize,nData,nScale);
delJ = zeros(hiddenSize*nScale,nData);
delSoftmax = zeros(hiddenSize*nScale,nData);
aTmp = zeros(hiddenSize*nScale,nData);
for iScale = 1:nScale
    iniIdx = 1+(iScale-1)*hiddenSize;
    endIdx = iScale*hiddenSize;
    aTmp(iniIdx:endIdx,:) = a{numLayers}(:,:,iScale);

%     aTmp = a{numLayers}(:,:,iScale);
%     softmaxThetaTmp = softmaxTheta(:,1+(iScale-1)*hiddenSize:iScale*hiddenSize);
%     delJ(:,:,iScale) = softmaxThetaTmp'*(groundTruth - p_y_given_x(aTmp, softmaxThetaTmp));
%     delSoftmax(:,:,iScale) = - delJ(:,:,iScale) .* sigmoidPrime(aTmp);

%     delJ = softmaxTheta'*(groundTruth - p_y_given_x(a{numLayers}, softmaxTheta));
%     delSoftmax = - delJ .* sigmoidPrime(a{numLayers});
end

if locationFeatFlag == 1
    aTmp = cat(1, aTmp, locations);
end
    
delJ = softmaxTheta'*(groundTruth - p_y_given_x(aTmp, softmaxTheta));
delSoftmax = - delJ.* sigmoidPrime(aTmp);

% NOTE: 

% del3 = delSoftmax;
del{numel(stack)+1} = zeros(hiddenSize, nData, nScale);
for iScale = 1:nScale
    iniIdx = 1+(iScale-1)*hiddenSize;
    endIdx = iScale*hiddenSize;
    del{numel(stack)+1}(:,:,iScale) = delSoftmax(iniIdx:endIdx,:);
end
% del2
for d = numel(stack):-1:1 % back prop
    del{d} = zeros(inputSize,nData);
    for iScale = 1:nScale
        wTmp = stack{d}.w(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:);
        bTmp = stack{d}.b(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:);
        
        del{d}(:,:,iScale) = (wTmp)'*del{d+1}(:,:,iScale).*sigmoidPrime(a{d}(:,:,iScale));
        
        % del{d} = ((stack{d}.w)'*del{d+1}).*sigmoidPrime(a{d});
        
    end
end

% del2 = ((stack{2}.w)'*delSoftmax).*sigmoidPrime(a{2});
% del1 = ((stack{1}.w)'*del2).*sigmoidPrime(a{1});

% % gradient and cost
% numLayers = numel(stack)+1;
% hiddenSizeLbeforeTop = size(stack{numel(stack)}.w,1);
% [softmaxThetaCost, softmaxThetaGrad] =...
%     softmaxCost(softmaxTheta, numClasses, hiddenSizeLbeforeTop, lambda, a{numLayers}, labels);

% gradient and cost
numLayers = numel(stack)+1;
hiddenSizeLbeforeTop = size(stack{numel(stack)}.w,1);

activation = zeros(hiddenSizeLbeforeTop, nData);
for iScale = 1:nScale
    activation(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:) = a{numLayers}(:,:,iScale);
end

if locationFeatFlag ==1
% get locations into business
activation = cat(1,activation, locations);
end

featureSize = size(activation,1); % when include location it's +2

[softmaxThetaCost, softmaxThetaGrad] =...
    softmaxCost(softmaxTheta, numClasses, featureSize, lambda, activation, labels);



% del{3} = delSoftmax;
% del{2} = del2;
% del{1} = del1;
% a{3} = a3;
% a{2} = a2;
% a{1} = a1;

for d = 1:numel(stack)
    stackgrad{d}.w = zeros(hiddenSizeLbeforeTop, inputSize);
    stackgrad{d}.b = zeros(hiddenSizeLbeforeTop, 1);
    for iScale = 1:nScale
    numData = size(a{d},2);
    stackgrad{d}.w(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:) = (del{d+1}(:,:,iScale)*a{d}(:,:,iScale)')/numData;
    stackgrad{d}.b(1+(iScale-1)*hiddenSize:iScale*hiddenSize,:) = sum(del{d+1}(:,:,iScale),2)/numData;
    end
end

% for d = 1:numel(stack)
%     numData = size(a{d},2);
%     stackgrad{d}.w = (del{d+1}*a{d}')/numData;
%     stackgrad{d}.b = sum(del{d+1},2)/numData;
% end

cost = softmaxThetaCost;

% -------------------------------------------------------------------------

%% Roll gradient vector
grad = [softmaxThetaGrad(:) ; stack2params(stackgrad)];

end

%% Auxillary Functions
function sigm = sigmoid(x) % sigmoid function
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
