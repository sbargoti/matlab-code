function [activation] = feedForwardAutoencoder(theta, hiddenSize, visibleSize, data)

% theta: trained weights from the autoencoder
% visibleSize: the number of input units (probably 64) 
% hiddenSize: the number of hidden units (probably 25) 
% data: Our matrix containing the training data as columns.  So, data(:,i) is the i-th training example. 
  
% We first convert theta to the (W1, W2, b1, b2) matrix/vector format, so that this 
% follows the notation convention of the lecture notes. 
useGPU = 0;
if useGPU == 1
    theta = gpuArray(theta);
    data = gpuArray(data);
end

W1 = reshape(theta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
b1 = theta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);

%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Compute the activation of the hidden layer for the Sparse Autoencoder.
numData = size(data,2);

a1 = data;

z2 = W1*a1 + repmat(b1,[1 numData]);

a2 = sigmoid(z2); % using sigmoid function

activation = a2;

if useGPU == 1
    activation = gather(activation);    
end
%-------------------------------------------------------------------

end

%-------------------------------------------------------------------
% Here's an implementation of the sigmoid function, which you may find useful
% in your computation of the costs and the gradients.  This inputs a (row or
% column) vector (say (z1, z2, z3)) and returns (f(z1), f(z2), f(z3)). 

function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));
end
