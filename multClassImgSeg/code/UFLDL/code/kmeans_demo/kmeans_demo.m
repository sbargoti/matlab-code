
% CIFAR_DIR='/path/to/cifar/cifar-10-batches-mat/';
currentPath = cd;
rootPath = currentPath(1:(strfind(currentPath,'work')+4)); % to work/
CIFAR_DIR = [rootPath 'dataSet\cifar-10-batches-mat'];
% CIFAR_DIR='D:\Users\Calvin\Dropbox\work\dataSet\cifar-10-batches-mat';


assert(~strcmp(CIFAR_DIR, '/path/to/cifar/cifar-10-batches-mat/'), ...
       ['You need to modify kmeans_demo.m so that CIFAR_DIR points to ' ...
        'your cifar-10-batches-mat directory.  You can download this ' ...
        'data from:  http://www.cs.toronto.edu/~kriz/cifar-10-matlab.tar.gz']);

%% Configuration
addpath minFunc;
rfSize = 6;
numCentroids=1600;
whitening=true;
numPatches = 400000;
CIFAR_DIM=[32 32 3];

%% Load CIFAR training data
fprintf('Loading training data...\n');
f1=load([CIFAR_DIR '/data_batch_1.mat']);
f2=load([CIFAR_DIR '/data_batch_2.mat']);
f3=load([CIFAR_DIR '/data_batch_3.mat']);
f4=load([CIFAR_DIR '/data_batch_4.mat']);
f5=load([CIFAR_DIR '/data_batch_5.mat']);

trainX = double([f1.data; f2.data; f3.data; f4.data; f5.data]); %[50000 3072]
trainY = double([f1.labels; f2.labels; f3.labels; f4.labels; f5.labels]) + 1; % add 1 to labels![50000 1]
clear f1 f2 f3 f4 f5;

% extract random patches
patches = zeros(numPatches, rfSize*rfSize*3); %[400000 108]
for i=1:numPatches
  if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
  
  r = random('unid', CIFAR_DIM(1) - rfSize + 1);
  c = random('unid', CIFAR_DIM(2) - rfSize + 1);
  patch = reshape(trainX(mod(i-1,size(trainX,1))+1, :), CIFAR_DIM);
  patch = patch(r:r+rfSize-1,c:c+rfSize-1,:);
  patches(i,:) = patch(:)';
end

% normalize for contrast
patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
% patches =  bsxfun(@minus, patches, mean(patches,2)); % what UFLDL site said std normalisation isn't necessary


% whiten
if (whitening)
  C = cov(patches); %[1 1]
  M = mean(patches);%[1 108]
  [V,D] = eig(C);   % V:[108 108] D:[108 108]
  P = V * diag(sqrt(1./(diag(D) + 0.1))) * V'; %P:[108 108]
  patches = bsxfun(@minus, patches, M) * P;
end

% run K-means
centroids = run_kmeans(patches, numCentroids, 50); %[1600 108]
show_centroids(centroids, rfSize); drawnow;

% extract training features
if (whitening)
  trainXC = extract_features(trainX, centroids, rfSize, CIFAR_DIM, M,P); %[50000 6400]
else
  trainXC = extract_features(trainX, centroids, rfSize, CIFAR_DIM);
end

% standardize data
trainXC_mean = mean(trainXC); %[1 6400]
trainXC_sd = sqrt(var(trainXC)+0.01); %[1 6400]
trainXCs = bsxfun(@rdivide, bsxfun(@minus, trainXC, trainXC_mean), trainXC_sd);
trainXCs = [trainXCs, ones(size(trainXCs,1),1)];

% train classifier using SVM
C = 100;
theta = train_svm(trainXCs, trainY, C); %[6401 10] size(trainY) = [50000  1]

[val,labels] = max(trainXCs*theta, [], 2); 
%
%size(trainXCs) =[50000 6401]
%size(theta) = [6401 10]
%size(trainXCs*theta) = [50000 10]
fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY) / length(trainY)));

%%%%% TESTING %%%%%

%% Load CIFAR test data
fprintf('Loading test data...\n');
f1=load([CIFAR_DIR '/test_batch.mat']);
testX = double(f1.data);
testY = double(f1.labels) + 1;
clear f1;

% compute testing features and standardize
if (whitening)
  testXC = extract_features(testX, centroids, rfSize, CIFAR_DIM, M,P);
else
  testXC = extract_features(testX, centroids, rfSize, CIFAR_DIM);
end
testXCs = bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd);
testXCs = [testXCs, ones(size(testXCs,1),1)];

% test and print result
[val,labels] = max(testXCs*theta, [], 2);
fprintf('Test accuracy %f%%\n', 100 * (1 - sum(labels ~= testY) / length(testY)));

