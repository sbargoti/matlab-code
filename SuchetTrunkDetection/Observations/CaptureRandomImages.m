% Crop images for labeling,
% lets us focus on the area of interest, producing better labels

clear all; close all; clc;

% Whole images
parentFolderProcessed = {['X:\mantis-shrimp\processed\',...
    '2014-03-31-melbourne-apples\2014-04-02-melbourne-apples\'];
    ['X:\mantis-shrimp\processed\',...
    '2013-10-08-melbourne-apples-processed\shrimp\'];
    ['X:\mantis-shrimp\processed\2013-03-apple-farm\shrimp\']};
parentFolderRaw = {['X:\mantis-shrimp\datasets\',...
    '2014-03-31-melbourne-apples\2014-04-02-melbourne-apples\'];
    ['X:\mantis-shrimp\datasets\',...
    '2013-10-08-melbourne-apples\shrimp\'];
    ['X:\mantis-shrimp\datasets\2013-03-apple-farm\shrimp\']};
log_name = {'e8n-to-e2s';'e8-3-v-rows';'e22-e6-d20-d14-slow';'e20-24-i-row';'e20-to-e24';'Run2';'Run3'};

parentFolder = parentFolderRaw{3};
log_name = log_name{7};

dataPath = [parentFolder, log_name,...
        '\ladybug\'];
d0=bin_load([dataPath,'index.bin'],'t,uw,ul');

% randomly select 50 images from loaded point cloud
randIDX = randperm(size(d0,1),50);
times = d0(randIDX,1);
times = sort(times);

% Output directory
parentFolder = parentFolderProcessed{3};
outputDirectory = [parentFolder, log_name, '\ladybug\images_cropped_undistorted_labels'];
if ~exist(outputDirectory,'dir')
    mkdir([outputDirectory,'\images'])
    mkdir([outputDirectory,'\labels'])
    mkdir([outputDirectory,'\training'])
end

bin_save_local(times,[parentFolder, log_name, '\ladybug\', 'randomTimes.bin'],'t');
return



% parentDirectory = [parentFolder,log_name, ...
%     '\trunk-segmentation\row', num2str(row_number),'\images\'];

% imageFiles = dir([parentDirectory,'*png']);
% imageNames = {imageFiles.name}';
% imagePath = cellfun(@(x) strcat(parentDirectory,x),imageNames,'UniformOutput',false);

% Work on multiple rows
row_numbers=1:10;
imagePath = []; imageNames=[];
for row_number = row_numbers
    parentDirectory = [parentFolder, log_name,...
        '\trunk-segmentation\row', num2str(row_number),'\images\'];
    imageFiles = dir([parentDirectory,'*png']);
    currentImageNames = {imageFiles.name}';
    imageNames = [imageNames; currentImageNames];
    imagePath = [imagePath; cellfun(@(x) strcat(parentDirectory,x),currentImageNames,'UniformOutput',false)];
end

% Output directory
outputDirectory = [parentFolder, log_name, '\ladybug\images_cropped_undistorted_labels'];
if ~exist(outputDirectory,'dir')
    mkdir([outputDirectory,'\images'])
    mkdir([outputDirectory,'\labels'])
    mkdir([outputDirectory,'\training'])
end

outputDirectory = [outputDirectory,'\images\'];

% Random sort
randIDX = randperm(length(imagePath),20);

% Go through images and cropt them
for i = randIDX
    % Load image
    inputImage = imread(imagePath{i});
    % Crop image
    cropImg = [380 889 1000 1339];
    inputImageCropped = inputImage(cropImg(3):cropImg(4),cropImg(1):cropImg(2),:);
    % Save image
    imwrite(inputImageCropped,[outputDirectory imageNames{i}(1:end-3) 'cropped.png'],'png')
end
