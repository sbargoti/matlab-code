% Second part of script containing trunk detection using images
% By this time, the mapping has been done in linux and the images have been
% classified using calvins code
function trunkSegmentationPart2(dataPath,modelPath,row_type)
% clear all; close all; clc;

%% Load data from face segmentation
% parentFolder = {['X:\mantis-shrimp\processed\',...
%     '2014-03-31-melbourne-apples\2014-04-02-melbourne-apples\'];
%     ['X:\mantis-shrimp\processed\',...
%     '2013-10-08-melbourne-apples-processed\shrimp\']};
% log_name = {'e8n-to-e2s';'e8-3-v-rows';'e22-e6-d20-d14-slow'};
% row_number = 2;
% parentFolder = parentFolder{1};
% log_name = log_name{1};
% dataPath = [parentFolder, log_name, ...
%     '\trunk-segmentation\row', num2str(row_number),'\'];
fprintf('Data Path is: \n %s \n',dataPath);
% Load data from the first half of the script
d = bin_load([dataPath, 'treeFace.bin'],'d,d,d,ui,ui');
treeFace = d(:,1:3); treeFaceIDX = d(:,end-1); treeFaceTrunkCandidates = d(:,end);
d = bin_load([dataPath, 'trunkCandidates.bin'], 't,d,d,d,ui,ui');
trunkCandidates = d(:,end);
% viewClusters(treeFace(:,1),treeFace(:,3),treeFaceTrunkCandidates)

%% Run image classification analysis
loadClassifiedRes = 1;
if loadClassifiedRes && exist([dataPath, 'classifiedClusters.bin'],'file')
    d3 = bin_load([dataPath, 'classifiedClusters.bin'],'d,ui,ui');
    clusterXPos = d3(:,1); pixelsPerCluster=d3(:,2);
else
%     modelPath = [parentFolder,log_name,...
%     '\ladybug\images_cropped_undistorted_labels\training\'];
    % [ clusterID, pixelsPerCluster ] = ImageClassificationObservation(dataPath,0);
    [ clusterID, pixelsPerCluster ] = ImageClassificationObservationV2(dataPath,modelPath,0);
    % viewClusterWithImageV2(treeFace(:,1),treeFace(:,3),treeFaceTrunkCandidates,dataPath,modelPath,16)
    % get mean x-position per cluster
    clusterXPos = zeros(length(clusterID),1);
    for i = 1:length(clusterID)
        xClusters = treeFace(treeFaceTrunkCandidates==clusterID(i),1);
        clusterXPos(i) = mean(xClusters);
    end
    [clusterXPos,sortOrder] = sort(clusterXPos);
    pixelsPerCluster = pixelsPerCluster(sortOrder);
    bin_save_local([clusterXPos,pixelsPerCluster,clusterID(sortOrder)],[dataPath, 'classifiedClusters.bin'],'d,ui,ui');
end

%% Re-aquire hough line observations
[linePos, lineEnds, lineLength, linePointsIDX] = LineFitObservations(treeFace,0,row_type);

%% Convert to observations suitable for the HSMM framework
s_width = 0.05;
slices = min(treeFace(:,1)):s_width:max(treeFace(:,1));
% Find the points that belong to the lines
idxPerSlice = DataToSlices(linePos,linePointsIDX,slices,'indices');

% Get observations using the old method
obsLaser = DataToSlices(linePos,lineLength,slices,'max');

% Get observations using the images
max_pixelsPerCluster = 100; % max threshold on pixel classification
obsImageMax = DataToSlices(clusterXPos,pixelsPerCluster,slices,'max');
obsImage = DataToSlices(clusterXPos,min(pixelsPerCluster,max_pixelsPerCluster),slices,'max');
% Find first and last image return

imageReturns = find(obsImage(:,2)>10);
keyboard
% Get observations as a combination of the two
% Visual analysis of the line fit data shows that it has a 100% recall.
% However sometimes during the image mapping due to classification
% inaccuracy and/or time sync problems between the laser and the camera,
% the image results can give false negative results. Therefore better
% results can be observed if we add some contribution from the laser data
% even through the laser data has a high rate of false positives
lineWeight = 5;
obsTotal = [obsImage(:,1), obsImage(:,2) + min(lineWeight,obsLaser(:,2)*10000)];

%% Perform HSMM inference using updated observations
% Initial probability distribution
PAI = [0 0 1]; % likely to start off at a dummy gap

% Duration parameters
mean_trunk_spacing = 1.5040;%1.5276; % Evaluated through ginput
std_trunk_spacing = 0.1551;%0.1722;
trunk_width = 0.1; % All units in metres
if strcmp(row_type,'i-structure');
    mean_trunk_spacing = 0.7994;
    std_trunk_spacing = 0.1589;
end

% observation paramters
obsTotal_distribution = [0 lineWeight 10 max(obsTotal(:,2))];
trunk_obsToProbab_map = [0.01 0.1 0.1 1];
gap_obsToProbab_map = [0.8 0.7 0.6 0.05]; % very low at the end as we are confident of a high recall

% Observation and duration probabilities
obsY = obsTotal(:,2);
obsX = obsTotal(:,1);
obsToProbab_map = [obsTotal_distribution;trunk_obsToProbab_map;gap_obsToProbab_map;gap_obsToProbab_map];
gap_duration = [mean_trunk_spacing std_trunk_spacing]/s_width;
trunk_duration = trunk_width/s_width;
[B,C] = GenerateHSMMParams(obsY,obsToProbab_map,gap_duration,trunk_duration);
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,B');

% Transition Matrix
% The trunk goes to a gap everywhere except at the end
% The gap can only go to a trunk
% The dummy gap can only go to a trunk
A = [0 29/30 1/30;1 0 0; 1 0 0];
Afcn = @(t) variableA(t,length(obsX)-(gap_duration(1)*0.75));

% Run inference
statesImage1 = HSMMInference(PAI,Afcn,B,C,obsY);

% Re-evaluate using new duration model
trunkIdxBottom = findIdxAtStates(idxPerSlice,statesImage1);
trunkIdxBottom = MergeWideStates(trunkIdxBottom);
new_gap_mean = mean(diff(cell2mat(trunkIdxBottom(:,1))));
new_gap_std = std(diff(cell2mat(trunkIdxBottom(:,1))));
fprintf('Gap duration updated from %1.3f %c %1.3f to %1.3f %c %1.3f\n',mean_trunk_spacing,char(177),std_trunk_spacing,new_gap_mean,char(177),new_gap_std)
gap_duration_new_image = [new_gap_mean new_gap_std]/s_width;
[B,C] = GenerateHSMMParams(obsY,obsToProbab_map,gap_duration_new_image,trunk_duration);
statesImage2 = HSMMInference(PAI,Afcn,B,C,obsY);

% Clear states before and after the end image returns
statesImage3 = statesImage2;
statesImage3(1:imageReturns(1)-3) = 0;
statesImage3(imageReturns(end)+3:end) = 0;
statesImage2 = statesImage3;

% Plot states
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,statesImage2');

%% Run HSMM inference using just the laser observations (old method)
test_old_method = 1;
if test_old_method
    fprintf('Acquiring results from the old method\n')
    % Observation parameters
    obsLaser_distribution = [0 0.2 0.3 max(obsLaser(:,2))];
    trunk_obsLaserToProbab_map = [0.01 0.1 0.1 1];
    gap_obsLaserToProbab_map = [0.8 0.7 0.6 0.05]; % very low at the end as we are confident of a high recall
    
    % Observation and duration probabilities
    obsLaserY = obsLaser(:,2);
    obsLaserX = obsLaser(:,1);
    obsLaserToProbab_map = [obsLaser_distribution;trunk_obsLaserToProbab_map;gap_obsLaserToProbab_map;gap_obsLaserToProbab_map];
    [BLaser, CLaser] = GenerateHSMMParams(obsLaserY,obsLaserToProbab_map,gap_duration,trunk_duration);
    % PlotLikelihoodsTEMP([treeFace(:,1) treeFace(:,3)],obsLaserX,BLaser');
    
    % Run inference
    statesLaser1 = HSMMInference(PAI,Afcn,BLaser,CLaser,obsLaserY);
    
    % Re-evaluate using new duration model
    tib = findIdxAtStates(idxPerSlice,statesLaser1);
    tib = MergeWideStates(tib);
    new_gap_mean = mean(diff(cell2mat(tib(:,1))));
    new_gap_std = std(diff(cell2mat(tib(:,1))));
    fprintf('Gap duration updated from %1.3f %c %1.3f to %1.3f %c %1.3f\n',mean_trunk_spacing,char(177),std_trunk_spacing,new_gap_mean,char(177),new_gap_std)
    gap_duration_new_laser = [new_gap_mean new_gap_std]/s_width;
    [BLaser,CLaser] = GenerateHSMMParams(obsLaserY,obsLaserToProbab_map,gap_duration_new_laser,trunk_duration);
    statesLaser2 = HSMMInference(PAI,Afcn,BLaser,CLaser,obsLaserY);
    % PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,statesLaser2');
end
%% Clean up data for output
% merge wide states into one
trunkIdxBottom = findIdxAtStates(idxPerSlice,statesImage2);
trunkIdxBottom = MergeWideStates(trunkIdxBottom);
trunkIdxBottomLaser = findIdxAtStates(idxPerSlice,statesLaser2);
trunkIdxBottomLaser = MergeWideStates(trunkIdxBottomLaser);

% Save results for future viewing
outputFolder = dataPath;
gap_duration_all = [gap_duration; gap_duration_new_image; gap_duration_new_laser]*s_width;
save([outputFolder,'segmentedTrunks.mat'],'obsTotal','B','BLaser','statesImage1','statesImage2','statesLaser1','statesLaser2','gap_duration_all','trunkIdxBottom','trunkIdxBottomLaser','obsImage','obsLaser')


