function [ clusterID, pixelsPerCluster ] = ImageClassificationObservation(dataPath,plot_on)
% function [ clusterID, pixelsPerCluster ] = ImageClassificationObservation(dataPath)
% datapath points to the processed data folder for the current row
% In its current form, need to make sure a folder exists called
% images-classified that has gone through calvins classification algorithm


% Check for the mapped laser to image binary files
inputBinFiles = dir([dataPath,'laser-to-camera\*.bin']);

% Initialise output
clusterID = zeros(length(inputBinFiles),1);
pixelsPerCluster = zeros(length(inputBinFiles),1);

% Initialise plot
if plot_on
    fh = figure('color','white');
end

fprintf('Evaluating image classification results per cluster \n');
h = waitbar(0,'Evaluating image classification results per cluster...');
% Go through each bin file, 
for i = 1:length(inputBinFiles)
    % Load laser mapping for the given cluster
    d=bin_load([dataPath,'laser-to-camera\',inputBinFiles(i).name],'t,t,t,d,d,d,d,d,d,ui,ui');
    imageFileName = [seconds2iso(d(1,1)),'.undistorted.png'];
    
    % Get cluster ID
    [~,binFileName,~] = fileparts(inputBinFiles(i).name);
    clusterID(i) = str2num(binFileName);
    
    % Get trunk candidate points on image
    trunkij = round(d(:,[4 5]));
    
    % load classified image 
    classifiedImgPath = [dataPath 'images-classified\',imageFileName(1:end-3),'Prob.png'];
    
    % Get number of classified points per cluster
    [pixelsPerCluster(i), ~] = ClassificationRateImageMask(zeros([1616 1232 3]), trunkij, classifiedImgPath);
    waitbar(i/length(inputBinFiles));
    
    % Plot options for debugging
    if plot_on
        img = imread([dataPath 'images\',imageFileName]);
        ClassificationRatePerCluster(img, trunkij, classifiedImgPath,fh);
        keyboard;
    end
end
close(h)

