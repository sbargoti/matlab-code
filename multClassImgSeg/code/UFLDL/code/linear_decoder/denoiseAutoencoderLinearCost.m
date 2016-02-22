function [cost,grad] = denoiseAutoencoderLinearCost(theta, visibleSize, hiddenSize, ...
                                                            lambda, sparsityParam, beta, data, corruptData)
% visibleSize: the number of input units (probably 64) 
% hiddenSize: the number of hidden units (probably 25) 
% lambda: weight decay parameter
% sparsityParam: The desired average activation for the hidden units (denoted in the lecture
%                           notes by the greek alphabet rho, which looks like a lower-case "p").
% beta: weight of sparsity penalty term
% data: Our 64x10000 matrix containing the training data.  So, data(:,i) is the i-th training example. 
  
% The input theta is a vector (because minFunc expects the parameters to be a vector). 
% We first convert theta to the (W1, W2, b1, b2) matrix/vector format, so that this 
% follows the notation convention of the lecture notes. 
useGPU = 0;

if useGPU == 1
    theta = gpuArray(theta);
    data = gpuArray(data);
end

% hidden weight
dimW1 = hiddenSize*visibleSize;
W1 = reshape(theta(1:dimW1), hiddenSize, visibleSize);
% visible weight (if W is tied W2 = W1', not the case here)
dimW2 = hiddenSize*visibleSize;
W2 = reshape(theta(dimW1+(1:dimW2)), visibleSize, hiddenSize);
% hidden bias
dimb1 = hiddenSize;
b1 = theta((dimW1+dimW2)+(1:dimb1));
% visible bias
dimb2 = visibleSize;
b2 = theta((dimW1+dimW2+dimb1)+(1:dimb2));



% % hidden weight
% W1 = reshape(theta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
% % visible weight (if W is tied W2 = W1', not the case here)
% W2 = reshape(theta(hiddenSize*visibleSize+1:2*hiddenSize*visibleSize), visibleSize, hiddenSize);
% % hidden bias
% b1 = theta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);
% % visible bias
% b2 = theta(2*hiddenSize*visibleSize+hiddenSize+1:end);

% Cost and gradient variables (your code needs to compute these values). 
% Here, we initialize them to zeros. 
cost = 0;
W1grad = zeros(size(W1));
W2grad = zeros(size(W2)); 
b1grad = zeros(size(b1)); 
b2grad = zeros(size(b2));



%% --------------- 1: forward propagation  
numData = size(data,2);
% layer 1 to 2

a1 = corruptData(:,1:numData);

z2 = W1*a1 + repmat(b1,[1 numData]);

a2 = sigmoid(z2); % using sigmoid function

% layer 2 to 3
z3 = W2*a2 + repmat(b2, [1 numData]);

% % output h = a3
% a3 = sigmoid(z3); % using sigmoid function
% h = a3; % reconstruction of data

% output linear decoder a3 = z3
a3 = z3; % using sigmoid function
h = a3; % reconstruction of data


%% ----------------- 2: backpropagation

%-------- 2.1 overall cost function J
% % 2.1.1 Reconstrution Error
% currently using traditional sum of squares, can try cross entropy "if
% input is interpreted as either bit vectors or vetors of bit probability"
% (what does that mean?)

squareError = 0.5*(h-data).^2;% Square Error
reconsErr = sum(sum(squareError,1))/numData;
% 
% crossEntropy = -(data.*log(h) + (1-data).*log(1-h));% Cross Entropy (somehow doesn't work, doesn't pass gradient test..)
% reconsErr = sum(sum(crossEntropy,1))/numData;

% %  2.1.2 weight decay to prevent overfitting
weightDecay = sum(sum(W1.^2))+sum(sum(W2.^2)); 

% %  2.1.3 sparsity constraints
rhohat = sum(a2,2)/numData; % average activation of hidden unit a2
rho = sparsityParam;

sparsityCost = sum(rho*log(rho./rhohat) ...
    + (1-rho)*log((1-rho)./(1-rhohat)));

% %  2.1.4 sum all the costs
cost = reconsErr ...
    + lambda/2 * weightDecay ...
    + beta * sparsityCost; 


% -------- 2.2 Gradient Calcuations

% %  2.2.1 del
% del3 = -(data - a3).*(a3.*(1-a3));
del3 = -(data - a3); % linear decoder

% del2 = (W2'*del3).*(a2.*(1-a2));

del2 = (W2'*del3 + repmat(beta*(-rho./rhohat+(1-rho)./(1-rhohat)),1,numData) ).*(a2.*(1-a2));
del1 = (W1'*del2).*(a1.*(1-a1));

% %  2.2.2 bias gradient
b1grad = sum(del2,2)/numData;
b2grad = sum(del3,2)/numData;

% %  2.2.3 weight gradient
% for i = 1:numData
%     W1grad = W1grad + del2(:,i)*a1(:,i)';
%     W2grad = W2grad + del3(:,i)*a2(:,i)';
% end
W1grad = (del2*a1')/numData + lambda * W1;
W2grad = (del3*a2')/numData + lambda * W2;

% W1grad = W1grad/numData;
% W2grad = W2grad/numData;

% W1grad = W1grad + lambda * W1;
% W2grad = W2grad + lambda * W2;

%-------------------------------------------------------------------
% After computing the cost and gradient, we will convert the gradients back
% to a vector format (suitable for minFunc).  Specifically, we will unroll
% your gradient matrices into a vector.

grad = [W1grad(:) ; W2grad(:) ; b1grad(:) ; b2grad(:)];

if useGPU == 1
    cost = gather(cost);
    grad = gather(grad);
end

end

%-------------------------------------------------------------------
% Here's an implementation of the sigmoid function, which you may find useful
% in your computation of the costs and the gradients.  This inputs a (row or
% column) vector (say (z1, z2, z3)) and returns (f(z1), f(z2), f(z3)). 

function sigm = sigmoid(x)
  
    sigm = 1 ./ (1 + exp(-x));
end



