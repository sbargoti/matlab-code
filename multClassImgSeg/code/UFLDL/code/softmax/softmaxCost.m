function [cost, grad] = softmaxCost(theta, numClasses, inputSize, lambda, data, labels)

% numClasses - the number of classes 
% inputSize - the size N of the input vector
% lambda - weight decay parameter
% data - the N x M input matrix, where each column data(:, i) corresponds to
%        a single test set
% labels - an M x 1 matrix containing the labels corresponding for the input data
%

% %     %%%%%%%%%!!!!!!!!!!!!!!!!!!!!!!!!!
% %     [data] = windowedNormalisation(data);
% %     %%%%%%%%%!!!!!!!!!!!!!!!!!!!!!!!!!

useGPU = 0; % not using GPU is faster (w/o GPU:10 sec, with GPU: 32.3 sec)

% Unroll the parameters from theta
theta = reshape(theta, numClasses, inputSize);

numCases = size(data, 2);

groundTruth = full(sparse(labels, 1:numCases, 1));
cost = 0;

thetagrad = zeros(numClasses, inputSize);

if useGPU == 1
    theta = gpuArray(theta);
    data = gpuArray(data);
end
    

% hypothesis 

h = p_y_given_x(data, theta, useGPU);

% Cost Function

J = -(1/numCases)*sum(sum(groundTruth.*log(h)));

weightDecay = 1/2*lambda * sum(sum(theta.^2));

cost = J + weightDecay;

% thetagrad


thetagrad = -(1/numCases)*((groundTruth - h)*data') + lambda* theta;


% ------------------------------------------------------------------
% Unroll the gradient matrices into a vector for minFunc
grad = [thetagrad(:)];

if useGPU == 1
    cost = gather(cost);
    grad = gather(grad);
end

end

% p_y_given_x using softmax
function hypothesis = p_y_given_x(data, theta, useGPU)

numClass = size(theta,1);

thetaTx = theta*data;
% prevent overflowing when exp(thetaTx) is too huge
if useGPU == 1
    thetaTx = thetaTx - repmat(max(thetaTx, [], 1), [size(thetaTx,1), 1]);
else
    thetaTx = bsxfun(@minus, thetaTx, max(thetaTx, [], 1));
end
expThetaTx = exp(thetaTx);

normF = sum(expThetaTx,1);

hypothesis = expThetaTx./repmat(normF, [numClass 1]);

end


