function [sparseAutoencoderLinearModel] = sparseAutoencoderLinearTrain(visibleSize, hiddenSize, ...
                                             lambda, sparsityParam, beta, data, theta)


if ~exist('options', 'var')
    options = struct;
end

if ~isfield(options, 'maxIter')
%     options.maxIter = 5;
    options.maxIter = 400;
%     options.maxIter = 1000;

end



% Use minFunc to minimize the function
% addpath minFunc/
options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % softmaxCost.m satisfies this.
minFuncOptions.display = 'on';



% hack to get around seg fault, matlab seems to have problem collecting
% memory garbage and crashes at 100 iteration, so for 400 steps
% optimistaion we break it down to several 50 steps optimisations

% for i = 1:9
%    [theta, cost] = minFunc( @(p) sparseAutoencoderLinearCost(p, ...
%                                    visibleSize, hiddenSize, ...
%                                    lambda, sparsityParam, ...
%                                    beta, data), ...
%                               theta, options);    
% end

[opttheta, cost] = minFunc( @(p) sparseAutoencoderLinearCost(p, ...
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

sparseAutoencoderLinearModel.opttheta = opttheta;
sparseAutoencoderLinearModel.W1 = W1;
sparseAutoencoderLinearModel.W2 = W2;
sparseAutoencoderLinearModel.b1 = b1;
sparseAutoencoderLinearModel.b2 = b2;
sparseAutoencoderLinearModel.visibleSize = visibleSize;
sparseAutoencoderLinearModel.hiddenSize = hiddenSize;
                          
end                          
