%% Sparse Autoencoder Test

%% Dependencies
currentPath = cd;
rootPath = currentPath(1:(strfind(currentPath,'work')+4)); % to work/
ufldlPath = [rootPath 'code/UFLDL/code/'];
% rootPath = '/home/calvin/code/UFLDL/code/';
addpath( [ufldlPath 'minFunc'])
addpath( [ufldlPath 'numericalGradient'])
addpath( [ufldlPath 'displayNetwork'])
addpath( [ufldlPath 'dataSet']) % small fast test data set
addpath( [ufldlPath 'dataSet/mnist']) % mnist digit data set



%%======================================================================
%% STEP 0: SparseAutoEncoder Parameters

% % Test data set setting
% patchSize = 8;
% visibleSize = patchSize^2;   % number of input units
% hiddenSize =25;     % number of hidden units (49 orig/theano uses 500/hinton uses 1000)
% sparsityParam = 0.01;   % desired average activation of the hidden units.
% % (This was denoted by the Greek alphabet rho, which looks like a lower-case "p",
% %  in the lecture notes).
% lambda = 0.0001;     % weight decay parameter (for L2 regularisation)
% beta = 3;            % weight of sparsity penalty term

% MNIST data set setting
patchSize = 28;
visibleSize = patchSize^2;   % number of input units 
hiddenSize = 196;     % number of hidden units 
sparsityParam = 0.1;   % desired average activation of the hidden units.
                     % (This was denoted by the Greek alphabet rho, which looks like a lower-case "p",
		     %  in the lecture notes). 
lambda = 3e-3;     % weight decay parameter       
beta = 3;            % weight of sparsity penalty term    

%%======================================================================
%% STEP 1: Sample patches from image

% % test image patch (for basic check)
% patches = sampleIMAGES(patchSize);
% display_network(patches(:,randi(size(patches,2),200,1)),8);

% MNIST dataset

images = loadMNISTImages('train-images.idx3-ubyte');
labels = loadMNISTLabels('train-labels.idx1-ubyte'); 
% We are using display_network from the autoencoder code
display_network(images(:,1:100)); % Show the first 100 images
disp(labels(1:10));

patches = images(:,1:10000);


%  Obtain random parameters theta
theta = initializeParameters(hiddenSize, visibleSize);

% %%======================================================================
% %% STEP 2: Implement sparseAutoencoderCost
% %
% %  You can implement all of the components (squared error cost, weight decay term,
% %  sparsity penalty) in the cost function at once, but it may be easier to do 
% %  it step-by-step and run gradient checking (see STEP 3) after each step.  We 
% %  suggest implementing the sparseAutoencoderCost function using the following steps:
% %
% %  (a) Implement forward propagation in your neural network, and implement the 
% %      squared error term of the cost function.  Implement backpropagation to 
% %      compute the derivatives.   Then (using lambda=beta=0), run Gradient Checking 
% %      to verify that the calculations corresponding to the squared error cost 
% %      term are correct.
% %
% %  (b) Add in the weight decay term (in both the cost function and the derivative
% %      calculations), then re-run Gradient Checking to verify correctness. 
% %
% %  (c) Add in the sparsity penalty term, then re-run Gradient Checking to 
% %      verify correctness.
% %
% %  Feel free to change the training settings when debugging your
% %  code.  (For example, reducing the training set size or 
% %  number of hidden units may make your code run faster; and setting beta 
% %  and/or lambda to zero may be helpful for debugging.)  However, in your 
% %  final submission of the visualized weights, please use parameters we 
% %  gave in Step 0 above.
% 
% [cost, grad] = sparseAutoencoderCost(theta, visibleSize, hiddenSize, lambda, ...
%                                      sparsityParam, beta, patches(:,1:5));
% 
% %%======================================================================
% %% STEP 3: Gradient Checking
% %
% % Hint: If you are debugging your code, performing gradient checking on smaller models 
% % and smaller training sets (e.g., using only 10 training examples and 1-2 hidden 
% % units) may speed things up.
% 
% % First, lets make sure your numerical gradient computation is correct for a
% % simple function.  After you have implemented computeNumericalGradient.m,
% % run the following: 
% % checkNumericalGradient();
% 
% % Now we can use it to check your cost function and derivative calculations
% % for the sparse autoencoder.  
% numgrad = computeNumericalGradient( @(x) sparseAutoencoderCost(x, visibleSize, ...
%                                                   hiddenSize, lambda, ...
%                                                   sparsityParam, beta, ...
%                                                   patches(:,1:5)), theta);
% 
% % Use this to visually compare the gradients side by side
% disp([numgrad grad]); 
% 
% % Compare numerically computed gradients with the ones obtained from backpropagation
% diff = norm(numgrad-grad)/norm(numgrad+grad);
% disp(diff); % Should be small. In our implementation, these values are
%             % usually less than 1e-9.
% 
%             % When you got this working, Congratulations!!! 

%%======================================================================
%% STEP 4: After verifying that your implementation of
%  sparseAutoencoderCost is correct, You can start training your sparse
%  autoencoder with minFunc (L-BFGS).

%  Randomly initialize the parameters
theta = initializeParameters(hiddenSize, visibleSize);

%  Use minFunc to minimize the function
% addpath minFunc/
options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % sparseAutoencoderCost.m satisfies this.
options.maxIter = 400;	  % Maximum number of iterations of L-BFGS to run 
options.display = 'on';

tic
[opttheta, cost] = minFunc( @(p) sparseAutoencoderCost(p, ...
                                   visibleSize, hiddenSize, ...
                                   lambda, sparsityParam, ...
                                   beta, patches), ...
                              theta, options);
toc
%%======================================================================
%% STEP 5: Visualization 

W1 = reshape(opttheta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
display_network(W1', 12); 

print -djpeg weights.jpg   % save the visualization to a file 


