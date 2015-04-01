% Script to call the trunk segmentation parts
clear all; close all; clc;

if ispc
    root_dir = 'X:\mantis-shrimp';
else 
    root_dir = '/home/suchet/data/mantis-shrimp-data';
end

parentFolder = {[root_dir, '\processed\',...
    '2014-03-31-melbourne-apples\2014-04-02-melbourne-apples\'];
    [root_dir, '\processed\',...
    '2013-10-08-melbourne-apples-processed\shrimp\'];
    [root_dir, '\processed\2013-03-apple-farm\shrimp\']};
log_name = {'e8n-to-e2s';'e8-3-v-rows';'e22-e6-d20-d14-slow';'e20-24-i-row';'e20-to-e24';'Run2';'Run3'};

% parentFolder = parentFolder{3};
% log_name = log_name{6};
parentFolder = parentFolder{1};
log_name = log_name{1};
row_numbers=1;%[3 4 9 10 11 12];
% row_numbers=[11 12];
row_numbers=2;%1:18;

row_type={'v-structure', 'i-structure'};
row_type = row_type{1};
% return
for row_number = row_numbers
    dataPath = [parentFolder, log_name,...
        '\trunk-segmentation\row', num2str(row_number),'\'];
    close all;
    dataPath = os_filename(dataPath);

    trunkSegmentationPart1(dataPath,row_number,row_type);
    
    modelPath = [parentFolder,log_name,...
    '\ladybug\images_cropped_undistorted_labels\training\'];
    modelPath = os_filename(modelPath);

%     trunkSegmentationPart2(dataPath,modelPath,row_type);
%   ViewSegmentationResults(dataPath,modelPath);
end

% ViewSegmentationResults(dataPath,modelPath);
% GetGroundTruth(dataPath,modelPath);