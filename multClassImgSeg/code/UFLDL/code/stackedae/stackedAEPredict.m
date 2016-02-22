function [pred] = stackedAEPredict(theta, inputSize, hiddenSize, numClasses, netconfig, data)
                                         
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

% We first extract the part which compute the softmax gradient
softmaxTheta = reshape(theta(1:hiddenSize*numClasses), numClasses, hiddenSize);

% Extract out the "stack"
stack = params2stack(theta(hiddenSize*numClasses+1:end), netconfig);

%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Compute pred using theta assuming that the labels start 
%                from 1.



a{1} = data;
for d = 1:numel(stack)
saeLOptTheta = [ stack{d}.w(:) ; stack{d}.w(:) ;stack{d}.b(:) ; stack{d}.b(:)  ];
hiddenSizeL = size(stack{d}.w,1);
visibleSizeL = size(stack{d}.w,2);
[a{d+1}] = feedForwardAutoencoder(saeLOptTheta, hiddenSizeL, ...
    visibleSizeL, a{d});
end


numLayers = numel(stack)+1;

h = p_y_given_x(a{numLayers}, softmaxTheta);

[maxVal, argmax] = max(h);

pred = argmax;





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
