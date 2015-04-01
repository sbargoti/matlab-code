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
    [ clusterID, pixelsPerCluster, totalPixelsPerCluster] = ImageClassificationObservationV2(dataPath,modelPath,0);
    % viewClusterWithImageV2(treeFace(:,1),treeFace(:,3),treeFaceTrunkCandidates,dataPath,modelPath,16)
    % get mean x-position per cluster
    clusterXPos = zeros(length(clusterID),1);
    for i = 1:length(clusterID)
        xClusters = treeFace(treeFaceTrunkCandidates==clusterID(i),1);
        clusterXPos(i) = mean(xClusters);
    end
    [clusterXPos,sortOrder] = sort(clusterXPos);
    pixelsPerCluster = pixelsPerCluster(sortOrder);
    totalPixelsPerCluster = totalPixelsPerCluster(sortOrder);
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
% X range
obsX = obsLaser(:,1); obsYLidar = obsLaser(:,2);

% Get observations using the images
max_pixelsPerCluster = 100; % max threshold on pixel classification
obsImageMax = DataToSlices(clusterXPos,pixelsPerCluster,slices,'max');
obsYImage = obsImageMax(:,2);
% obsImageMax(obsImageMax(:,2)~=0,2) = obsImageMax(obsImageMax(:,2)~=0,2);
obsImage = DataToSlices(clusterXPos,min(pixelsPerCluster,max_pixelsPerCluster),slices,'max');
% Find first and last image return
imageReturns = find(obsImage(:,2)>10);



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
% mean diff is 1.19 for T-block and 1.52 for e and d block
mean_trunk_spacing = 1.50;%1.19;%1.5040;%1.5276; % Evaluated through ginput
std_trunk_spacing = 0.1551;%0.1722;
trunk_width = 0.1; % All units in metres
if strcmp(row_type,'i-structure');
    mean_trunk_spacing = 0.754;
    std_trunk_spacing = 0.10;
end

% Duration parameters
gap_duration = [mean_trunk_spacing std_trunk_spacing]/s_width;
trunk_duration = trunk_width/s_width;

% Lidar observations
lidar_obs_distribution = [0 0.2 0.4 0.5];
lidar_trunk_prob = [0.02 0.1 0.7 0.7];
lidar_gap_prob = 1-lidar_trunk_prob;
% load('temp-learnt-obs-pre-harvest-data1-lidar')
lidar_obs_mapping= [lidar_obs_distribution;lidar_trunk_prob;lidar_gap_prob;lidar_gap_prob];
[Blidar,Clidar] = GenerateHSMMParams(obsYLidar,lidar_obs_mapping,gap_duration,trunk_duration);

% image observations
image_obs_distribution = [0 10 200 max(obsImageMax(:,2))];
image_trunk_prob = [0.1 0.25 0.8 0.8];
image_gap_prob = 1 - image_trunk_prob;
% load('temp-learnt-obs-pre-harvest-data1-image')
% image_obs_distribution(image_obs_distribution>=max(obsImageMax(:,2))) = [];
% image_obs_distribution = [image_obs_distribution max(obsImageMax(:,2))];
% image_trunk_prob = [image_trunk_prob max(image_trunk_prob)];
% image_gap_prob = [image_gap_prob min(image_gap_prob)];
image_obs_mapping= [image_obs_distribution;image_trunk_prob;image_gap_prob;image_gap_prob];
[Bimage,C] = GenerateHSMMParams(obsYImage,image_obs_mapping,gap_duration,trunk_duration);

% Combine observations
B = Blidar.*Bimage;
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,B');

% Transition Matrix
% The trunk goes to a gap everywhere except at the end
% The gap can only go to a trunk
% The dummy gap can only go to a trunk
A = [0 29/30 1/30;1 0 0; 1 0 0];
Afcn = @(t) variableA(t,length(obsX)-(gap_duration(1)*0.75));
% keyboard
% Run inference
statesImage1 = HSMMInference(PAI,Afcn,B,C,obsYImage);
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,statesImage1');

% Re-evaluate using new duration model
trunkIdxBottom = findIdxAtStates(idxPerSlice,statesImage1);
trunkIdxBottom = MergeWideStates(trunkIdxBottom);

new_gap_mean = mean(diff(cell2mat(trunkIdxBottom(:,1))));
new_gap_std = std(diff(cell2mat(trunkIdxBottom(:,1))));
fprintf('Gap duration updated from %1.3f %c %1.3f to %1.3f %c %1.3f\n',mean_trunk_spacing,char(177),std_trunk_spacing,new_gap_mean,char(177),new_gap_std)
gap_duration_new_image = [new_gap_mean new_gap_std]/s_width;
[~,C] = GenerateHSMMParams(obsYImage,image_obs_mapping,gap_duration_new_image,trunk_duration);
statesImage2 = HSMMInference(PAI,Afcn,B,C,obsYImage);
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,statesImage2');

% Clear states before and after the end image returns
% statesImage3 = statesImage2;
% statesImage3(1:imageReturns(1)-3) = 0;
% statesImage3(imageReturns(end)+3:end) = 0;
% statesImage2 = statesImage3;

% Plot states
PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,statesImage2');

%% Run HSMM inference using just the laser observations (old method)
test_old_method = 1;
if test_old_method
    fprintf('Acquiring results from the old method\n')
    % PlotLikelihoodsTEMP([treeFace(:,1) treeFace(:,3)],obsLaserX,BLidar');
    % Run inference
    statesLaser1 = HSMMInference(PAI,Afcn,Blidar,Clidar,obsYLidar);
    
    % Re-evaluate using new duration model
    tib = findIdxAtStates(idxPerSlice,statesLaser1);
    tib = MergeWideStates(tib);
    new_gap_mean = mean(diff(cell2mat(tib(:,1))));
    new_gap_std = std(diff(cell2mat(tib(:,1))));
    fprintf('Gap duration updated from %1.3f %c %1.3f to %1.3f %c %1.3f\n',mean_trunk_spacing,char(177),std_trunk_spacing,new_gap_mean,char(177),new_gap_std)
    gap_duration_new_laser = [new_gap_mean new_gap_std]/s_width;
    [~,Clidar] = GenerateHSMMParams(obsYLidar,lidar_obs_mapping,gap_duration_new_laser,trunk_duration);
    statesLaser2 = HSMMInference(PAI,Afcn,Blidar,Clidar,obsYLidar);
    PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,statesLaser2');
end
% keyboard
%% TEMP PART - TEST IF REDOING THE OBSERVATION MODEL HELPS OUT OR NOT
% [imageObsL, pixelBins, lidarObsL, lengthBins] = observationModelStats(dataPath,'inference',v2struct(obsTotal,statesImage2,statesLaser2,obsYImage,obsYLidar));
% [imageObsL, pixelBins, lidarObsL, lengthBins] = observationModelStats(dataPath,'ground-truth',v2struct(obsTotal,statesImage2,statesLaser2,obsYImage,obsYLidar));
% 
% imageObsL = imageObsL./repmat(sum(imageObsL,2),1,size(imageObsL,2));
% lidarObsL = lidarObsL./repmat(sum(lidarObsL,2),1,size(lidarObsL,2));
% 
% 
% 
% %%%% lidar
% lidar_obs_distribution = [lengthBins 0.5];
% lidar_trunk_prob = [lidarObsL(1,:) lidarObsL(1,end)];
% lidar_gap_prob = [lidarObsL(2,:) lidarObsL(2,end)];
% lidar_obs_mapping= [lidar_obs_distribution;lidar_trunk_prob;lidar_gap_prob;lidar_gap_prob];
% [Blidar,~] = GenerateHSMMParams(obsYLidar,lidar_obs_mapping,gap_duration,trunk_duration);
% 
% %%%% image
% image_obs_distribution = [pixelBins max(obsImageMax(:,2))];
% image_trunk_prob = [imageObsL(1,:) imageObsL(1,end)];
% image_gap_prob = [imageObsL(2,:) imageObsL(2,end)];
% image_obs_mapping= [image_obs_distribution;image_trunk_prob;image_gap_prob;image_gap_prob];
% [Bimage,~] = GenerateHSMMParams(obsYImage,image_obs_mapping,gap_duration,trunk_duration);
% 
% % Combine observations
% B = Blidar.*Bimage;
% 
% % Re run inference
% statesImage2 = HSMMInference(PAI,Afcn,B,C,obsYImage);
% statesLaser2 = HSMMInference(PAI,Afcn,Blidar,Clidar,obsYLidar);
% 
% % Clear states before and after the end image returns
% statesImage3 = statesImage2;
% statesImage3(1:imageReturns(1)-3) = 0;
% statesImage3(imageReturns(end)+3:end) = 0;
% statesImage2 = statesImage3;

%% Clean up data for output
% merge wide states into one
trunkIdxBottom = findIdxAtStates(idxPerSlice,statesImage2);
trunkIdxBottom = MergeWideStates(trunkIdxBottom);
trunkIdxBottomLaser = findIdxAtStates(idxPerSlice,statesLaser2);
trunkIdxBottomLaser = MergeWideStates(trunkIdxBottomLaser);

% Save results for future viewing
outputFolder = dataPath;
gap_duration_all = [gap_duration; gap_duration_new_image; gap_duration_new_laser]*s_width;
% load([outputFolder,'segmentedTrunks.mat'],'gtPoints');
% save([outputFolder,'segmentedTrunks.mat'],'obsTotal','obsYImage','obsYLidar','B','Blidar','statesImage2','statesLaser2','gap_duration_all','trunkIdxBottom','trunkIdxBottomLaser','gtPoints')
% keyboard
if exist([dataPath,'segmentedTrunks.mat'],'file')
    save([outputFolder,'segmentedTrunks.mat'],'obsTotal','obsYImage','obsYLidar','B','Blidar','statesImage2','statesLaser2','gap_duration_all','trunkIdxBottom','trunkIdxBottomLaser','-append')
else
    save([outputFolder,'segmentedTrunks.mat'],'obsTotal','obsYImage','obsYLidar','B','Blidar','statesImage2','statesLaser2','gap_duration_all','trunkIdxBottom','trunkIdxBottomLaser')
end

