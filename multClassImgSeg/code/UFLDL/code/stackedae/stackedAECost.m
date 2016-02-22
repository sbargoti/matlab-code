function [ cost, grad ] = stackedAECost(theta, inputSize, hiddenSize, ...
                                              numClasses, netconfig, ...
                                              lambda, data, labels)
                                         
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


%% Unroll softmaxTheta parameter

% We first extract the part which compute the softmax gradient
softmaxTheta = reshape(theta(1:hiddenSize*numClasses), numClasses, hiddenSize);

% Extract out the "stack"
stack = params2stack(theta(hiddenSize*numClasses+1:end), netconfig);

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
groundTruth = full(sparse(labels, 1:M, 1));


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
saeLOptTheta = [ stack{d}.w(:) ; stack{d}.w(:) ;stack{d}.b(:) ; stack{d}.b(:)  ];
hiddenSizeL = size(stack{d}.w,1);
visibleSizeL = size(stack{d}.w,2);
[a{d+1}] = feedForwardAutoencoder(saeLOptTheta, hiddenSizeL, ...
    visibleSizeL, a{d});
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

% dels
numLayers = numel(stack)+1;
delJ = softmaxTheta'*(groundTruth - p_y_given_x(a{numLayers}, softmaxTheta));
delSoftmax = - delJ .* sigmoidPrime(a{numLayers});

del{3} = delSoftmax;
for d = numel(stack):-1:1 % back prop
del{d} = ((stack{d}.w)'*del{d+1}).*sigmoidPrime(a{d});
end
% del2 = ((stack{2}.w)'*delSoftmax).*sigmoidPrime(a{2});
% del1 = ((stack{1}.w)'*del2).*sigmoidPrime(a{1});

% gradient and cost
numLayers = numel(stack)+1;
hiddenSizeLbeforeTop = size(stack{numel(stack)}.w,1);
[softmaxThetaCost, softmaxThetaGrad] =...
    softmaxCost(softmaxTheta, numClasses, hiddenSizeLbeforeTop, lambda, a{numLayers}, labels);


% del{3} = delSoftmax;
% del{2} = del2;
% del{1} = del1;
% a{3} = a3;
% a{2} = a2;
% a{1} = a1;

for d = 1:numel(stack)
    numData = size(a{d},2);
    stackgrad{d}.w = (del{d+1}*a{d}')/numData;
    stackgrad{d}.b = sum(del{d+1},2)/numData;
end

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
