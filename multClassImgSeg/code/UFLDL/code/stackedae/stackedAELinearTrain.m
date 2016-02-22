function [stackedAEModel] = stackedAELinearTrain(inputSize, hiddenSize, numClasses,...
    netconfig, lambda, data, locations, labels, theta, nScale, locationFeatFlag)
%softmaxTrain Train a softmax model with the given parameters on the given
% data. Returns softmaxOptTheta, a vector containing the trained parameters
% for the model.
%
% inputSize: the size of an input vector x^(i)
% numClasses: the number of classes 
% lambda: weight decay parameter
% inputData: an N by M matrix containing the input data, such that
%            inputData(:, c) is the cth input
% labels: M by 1 matrix containing the class labels for the
%            corresponding inputs. labels(c) is the class label for
%            the cth input
% options (optional): options
%   options.maxIter: number of iterations to train for

if ~exist('options', 'var')
    options = struct;
end

if ~isfield(options, 'maxIter')
%     options.maxIter = 400;
    options.maxIter = 2000;
% options.maxIter = 500;
end



% Use minFunc to minimize the function
% addpath minFunc/
options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % softmaxCost.m satisfies this.
minFuncOptions.display = 'on';


% 
% [cost, grad] = stackedAECost(stackedAETheta, inputSize, hiddenSize, ...
%                              numClasses, netconfig, ...
%                              lambda, data, labels);

[stackedAEOptTheta, cost] = minFunc( @(p) stackedAELinearCost(p, ...
                                   inputSize, hiddenSize, ...
                             numClasses, netconfig, ...
                             lambda, data, locations, labels, nScale, locationFeatFlag), ...                                   
                              theta, options);

% Fold stackedAEOptTheta into a nicer format
stackedAEModel.optTheta = stackedAEOptTheta;
stackedAEModel.inputSize = inputSize;
stackedAEModel.hiddenSize = hiddenSize;
stackedAEModel.numClasses = numClasses;
stackedAEModel.netconfig = netconfig;
stackedAEModel.lambda = lambda;
stackedAEModel.nScale = nScale;
stackedAEModel.locationFeatFlag = locationFeatFlag;
                          
end                          
