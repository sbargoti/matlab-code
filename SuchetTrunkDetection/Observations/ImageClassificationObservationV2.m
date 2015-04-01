function [ clusterID, pixelsPerCluster, totalPixelsPerCluster ] = ImageClassificationObservationV2(dataPath,modelPath,plot_on)
% function [ clusterID, pixelsPerCluster, totalPixelsPerCluster ] = ImageClassificationObservationV2(dataPath,modelPath,plot_on)
% datapath points to the processed data folder for the current row
% Upgrade from V1: doesn't need preclassified images anymore, can classify
% on the go based on a saved model

% Check for the mapped laser to image binary files
inputBinFiles = dir([dataPath,'laser-to-camera\*.bin']);

% Initialise output
clusterID = zeros(length(inputBinFiles),1);
pixelsPerCluster = zeros(length(inputBinFiles),1);
totalPixelsPerCluster = zeros(length(inputBinFiles),1);

% Initialise plot
if plot_on
    fh = figure('color','white');
else
    fh = 0;
end

% Load model for classification
% Path to .mat files containig the trained model
% modelPath = ['X:\mantis-shrimp\processed\',...
%     '2013-10-08-melbourne-apples-processed\shrimp\e22-e6-d20-d14-slow\',...
%     'ladybug\images_cropped_undistorted_labels\training\'];
fprintf('Path containing trained classification models \n %s \n',modelPath);
load([modelPath 'sae1OptThetaRGB.mat']);
load([modelPath 'stackedRelatedParaRGB.mat']);
load([modelPath 'stackedAEOptThetaRGB.mat']);
load([modelPath 'saeRelatedParaRGB.mat']);

% Add calvins code
% Path to calvins classification folder
classFcnPath = 'D:\Code\matlab\multClassImgSeg\';
fprintf('Path containing Calvins classification code \n %s \n', classFcnPath);
addpath( [classFcnPath 'code\Projects\multiClassImageSeg'] );
addpath( [classFcnPath 'code\Projects\multiClassImageSeg\suchetFunctions'] );
addpath( [classFcnPath 'code/UFLDL/code/' 'multiScaleUFL'] )% for vec_white_image
addpath( [classFcnPath 'code/UFLDL/code/' 'stackedae'] )% for stackedAEPredict
addpath( [classFcnPath 'code/UFLDL/code/' 'stl'] ) % for feed forward auto encoder

fprintf('Evaluating image classification results per cluster \n');
h = waitbar(0,'Evaluating image classification results per cluster...');
% Go through each bin file, 
for i = 1:length(inputBinFiles)
    % Load laser mapping for the given cluster
    d=bin_load([dataPath,'laser-to-camera\',inputBinFiles(i).name],'t,t,t,d,d,d,d,d,d,ui,ui');
    imageFileName = [seconds2iso(d(1,1)),'.undistorted.png'];
    img = imread([dataPath 'images\',imageFileName]);
    
    % Get cluster ID
    [~,binFileName,~] = fileparts(inputBinFiles(i).name);
    clusterID(i) = str2num(binFileName);
    
    % Get trunk candidate points on image
    trunkij = round(d(:,[4 5]));
    % Make sure the image points are within range
    prevSize = size(trunkij,1);
    trunkij(trunkij(:,2)>size(img,1),:)=[]; trunkij(trunkij(:,2)<1,:)=[];
    trunkij(trunkij(:,1)>size(img,2),:)=[]; trunkij(trunkij(:,1)<1,:)=[];
    newSize = size(trunkij,1);
    if prevSize-newSize
        fprintf('Size of pixel points reduced by %2.2f percent due to outliers\n',(prevSize-newSize)/prevSize*100);
    end
    
    % load classified image 
    classifiedImgPath = [dataPath 'images-classified\',imageFileName(1:end-3),'Prob.png'];
    
    
    % Get number of classified points per cluster
%     [pixelsPerCluster(i), ~] = ClassificationRateImageMask(zeros([1616 1232 3]), trunkij, classifiedImgPath);
    [pixelsPerCluster(i), totalPixelsPerCluster(i)] = ClassificationRatePixel(img, trunkij, fh,  meanPatch, ZCAWhite, stackedAEOptTheta, numClasses, netconfig);
    waitbar(i/length(inputBinFiles));
    
end
close(h)

