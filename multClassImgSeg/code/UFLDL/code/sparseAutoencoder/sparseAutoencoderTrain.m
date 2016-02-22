function [sparseAutoencoderModel] = sparseAutoencoderTrain(visibleSize, hiddenSize, ...
                                             lambda, sparsityParam, beta, data, theta)


if ~exist('options', 'var')
    options = struct;
end

if ~isfield(options, 'maxIter')
    options.maxIter = 400;
end



% Use minFunc to minimize the function
% addpath minFunc/
options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % softmaxCost.m satisfies this.
minFuncOptions.display = 'on';


[opttheta, cost] = minFunc( @(p) sparseAutoencoderCost(p, ...
                                   visibleSize, hiddenSize, ...
                                   lambda, sparsityParam, ...
                                   beta, data), ...
                              theta, options);

% Fold sparseAutoencoderModel into a nicer format

% hidden weight
dimW1 = hiddenSize*visibleSize;
W1 = reshape(opttheta(1:dimW1), hiddenSize, visibleSize);
% visible weight (if W is tied W2 = W1', not the case here)
dimW2 = hiddenSize*visibleSize;
W2 = reshape(opttheta(dimW1+(1:dimW2)), visibleSize, hiddenSize);
% hidden bias
dimb1 = hiddenSize;
b1 = opttheta((dimW1+dimW2)+(1:dimb1));
% visible bias
dimb2 = visibleSize;
b2 = opttheta((dimW1+dimW2+dimb1)+(1:dimb2));

sparseAutoencoderModel.opttheta = opttheta;
sparseAutoencoderModel.W1 = W1;
sparseAutoencoderModel.W2 = W2;
sparseAutoencoderModel.b1 = b1;
sparseAutoencoderModel.b2 = b2;
sparseAutoencoderModel.visibleSize = visibleSize;
sparseAutoencoderModel.hiddenSize = hiddenSize;
                          
end                          
