function [cost, grad] = sparseCodingFeatureCost(weightMatrix, featureMatrix, visibleSize, numFeatures, patches, gamma, lambda, epsilon, groupMatrix)
%sparseCodingFeatureCost - given the weights in weightMatrix,
%                          computes the cost and gradient with respect to
%                          the features, given in featureMatrix
% parameters
%   weightMatrix  - the weight matrix. weightMatrix(:, c) is the cth basis
%                   vector.
%   featureMatrix - the feature matrix. featureMatrix(:, c) is the features
%                   for the cth example
%   visibleSize   - number of pixels in the patches
%   numFeatures   - number of features
%   patches       - patches
%   gamma         - weight decay parameter (on weightMatrix)
%   lambda        - L1 sparsity weight (on featureMatrix)
%   epsilon       - L1 sparsity epsilon
%   groupMatrix   - the grouping matrix. groupMatrix(r, :) indicates the
%                   features included in the rth group. groupMatrix(r, c)
%                   is 1 if the cth feature is in the rth group and 0
%                   otherwise.

    if exist('groupMatrix', 'var')
        assert(size(groupMatrix, 2) == numFeatures, 'groupMatrix has bad dimension');
    else
        groupMatrix = eye(numFeatures);
    end

    numExamples = size(patches, 2);

    weightMatrix = reshape(weightMatrix, visibleSize, numFeatures);
    featureMatrix = reshape(featureMatrix, numFeatures, numExamples);

    % -------------------- YOUR CODE HERE --------------------
    % Instructions:
    %   Write code to compute the cost and gradient with respect to the
    %   features given in featureMatrix.     
    %   You may wish to write the non-topographic version, ignoring
    %   the grouping matrix groupMatrix first, and extend the 
    %   non-topographic version to the topographic version later.
    % -------------------- YOUR CODE HERE --------------------
    
    dJds = zeros(size(featureMatrix));
    x = patches;
    A = weightMatrix;
    s = featureMatrix;
    V = groupMatrix;
    % fix featureMatrix, change weightMatrix, cost on weight only
    
    % cost
    reconsErr = sum(sum((A*s - x).^2))/numExamples;
    L1norm = lambda*sum(sum(sqrt(s.^2 + epsilon))); % related to feature

%     L1norm = lambda*sum(sum(sqrt(V*s*s'+ epsilon))); % related to feature
        
    cost =  reconsErr + L1norm; 
%     cost =  reconsErr; 
%       cost = L1norm;

    
    % gradient dJ/dA 
    
%     dJdA = 2*(A*s - x)*s'/numExamples + 2*gamma*A;

    dJds =  2*A'*(A*s - x)/numExamples + lambda*(s.^2+ epsilon).^(-1/2).*s;
%       dJds =  lambda*(s.^2+ epsilon).^(-1/2).*s;

      
%     dJds =  2*A'*(A*s - x)/numExamples + lambda*((V*s*s'+ epsilon).^(-1/2))'*V*s;
%     dJds =  lambda*    ((V*s*s'+ epsilon).^(-1/2))'*(V*s);




    grad = dJds(:);
    
    
    
    
end