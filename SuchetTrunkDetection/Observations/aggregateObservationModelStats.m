% Check the validity of the observation model by observing the observation
% likelihoods from ground truth data.
% close all; clear all; clc
clear all; clc
% Initialise data directories
parentFolder = {['X:\mantis-shrimp\processed\',...
    '2014-03-31-melbourne-apples\2014-04-02-melbourne-apples\'];
    ['X:\mantis-shrimp\processed\',...
    '2013-10-08-melbourne-apples-processed\shrimp\'];
    ['X:\mantis-shrimp\processed\2013-03-apple-farm\shrimp\']};
log_name = {'e8n-to-e2s';'e8-3-v-rows';'e22-e6-d20-d14-slow';'e20-24-i-row';'e20-to-e24';'Run2';'Run3'};

% Data combinations
dataComb(1).pF = 2; dataComb(1).lN = 2; dataComb(1).rws = 1:12; dataComb(1).gtrws = 1:12;
dataComb(2).pF = 2; dataComb(2).lN = 3; dataComb(2).rws = [1,5,6,7,8]; dataComb(2).gtrws = [1,5,6,7,8];
dataComb(3).pF = 2; dataComb(3).lN = 4; dataComb(3).rws = 1:10; dataComb(3).gtrws = 1:2:9;
dataComb(4).pF = 1; dataComb(4).lN = 1; dataComb(4).rws = 1:12; dataComb(4).gtrws = 1:12;
dataComb(5).pF = 1; dataComb(5).lN = 5; dataComb(5).rws = 1:10; dataComb(5).gtrws = 1:2:9;
dataComb(6).pF = 3; dataComb(6).lN = 6; dataComb(6).rws = 1:10; dataComb(6).gtrws = 1:10;
dataComb(7).pF = 3; dataComb(7).lN = 7; dataComb(7).rws = 1:17; dataComb(7).gtrws = [];

% Comparing to either gt or inference results
analysisType = {'ground-truth','inference'};
analysisType = analysisType{1};

% Initialise observation parameters
imageObsL = [];
lidarObsL = [];
% Iterate through data
datasetIter = 3;
for dataSet = datasetIter
    
    % State current data
    currentParentFolder = parentFolder{dataComb(dataSet).pF};
    currentLog_name = log_name{dataComb(dataSet).lN};
    if strcmp(analysisType,'ground-truth')
        row_numbers = dataComb(dataSet).gtrws;
    elseif strcmp(analysisType,'inference');
        row_numbers = dataComb(dataSet).rws;
    end

    for row_number = row_numbers
        dataPath = [currentParentFolder, currentLog_name,...
            '\trunk-segmentation\row', num2str(row_number),'\'];
        [currentImageObsL, pixelBins, currentLidarObsL, lengthBins] = observationModelStats(dataPath,analysisType);
        imageObsL = cat(3,imageObsL,currentImageObsL);
        lidarObsL = cat(3,lidarObsL,currentLidarObsL);
    end
end
% Normalise the observation data
imageObsL = sum(imageObsL,3);
lidarObsL = sum(lidarObsL,3);
imageObsL = imageObsL./[sum(imageObsL,1);sum(imageObsL,1)];
lidarObsL = lidarObsL./[sum(lidarObsL,1);sum(lidarObsL,1)];
% imageObsL = imageObsL./repmat(sum(imageObsL,2),1,size(imageObsL,2));
% lidarObsL = lidarObsL./repmat(sum(lidarObsL,2),1,size(lidarObsL,2));
% Remove Nan entries
lidarNans = isnan(lidarObsL(1,:));
pixelNans = isnan(imageObsL(1,:));
lengthBins(lidarNans) = []; lidarObsL(:,lidarNans) = [];
pixelBins(pixelNans) = []; imageObsL(:,pixelNans) = [];

% Plot net observation models
% Observation model for lidar
f1 = figure('color','white');
plot(lengthBins,lidarObsL(1,:),'r-','linewidth',2)
hold on;
plot(lengthBins,lidarObsL(2,:),'b--','linewidth',2)
ax1 = gca;
xlabel('Fitted line length (m)','FontSize',16)
ylabel('Observation likelihood','FontSize',16)
[h_legend,objh,~,~] = legend('Trunk','Gap/Row-end');
set(objh,'linewidth',4);
set(h_legend,'FontSize',16,'Position',[0.5604    0.7424    0.3411    0.1762])
title('Learnt State likelihood for lidar observations','FontSize',16);
xlim([0 0.45])
% strX = {'0','0.1','0.2','0.3','0.4','Max'};
% set(gca,'XTick',[0 0.1 0.2 0.3 0.4 0.5],'XTickLabel',strX,'FontSize',16)
set(gca,'FontSize',16)

% Observation model for images
f2 = figure('color','white');
plot(pixelBins,imageObsL(1,:),'r-','linewidth',2)
hold on;
plot(pixelBins,imageObsL(2,:),'b--','linewidth',2)
ax2 = gca;
xlabel('Number of pixels classified as trunks','FontSize',16);
ylabel('Observation likelihood','FontSize',16)
[h_legend,objh,~,~] = legend('Trunk','Gap/Row-end');
set(h_legend,'FontSize',16,'Position',[0.5604    0.7324    0.3411    0.1762])
set(objh,'linewidth',4);
title('Learnt State likelihood for image observations','FontSize',16);
% strX = {'0','50','100','150','200','Max'};
xlim([0 600])
% set(gca,'XTick',[0 50 100 150 200 220],'XTickLabel',strX,'FontSize',16)
set(gca,'FontSize',16)
%% generate smooth curves for the lidar and image data
% smooth out lidar curves
xvec = linspace(0,0.5,50);
yvec = smooth(xvec,interp1(lengthBins,lidarObsL(1,:),xvec,'linear'),25);
lidar_obs_distribution = xvec;
lidar_trunk_prob = yvec';
lidar_trunk_prob = lidar_trunk_prob+0.005; % can sometimes be zero
lidar_gap_prob = 1-lidar_trunk_prob;
plot(ax1,lidar_obs_distribution,lidar_trunk_prob,'r','linewidth',5)
plot(ax1,lidar_obs_distribution,lidar_gap_prob,'b--','linewidth',5);
% save(sprintf('temp-learnt-obs-pre-harvest-data%d-lidar.mat',datasetIter),'lidar_obs_distribution','lidar_trunk_prob','lidar_gap_prob');

% smooth out image curves
xvec = linspace(0,700,500);
yvec = smooth(xvec,interp1(pixelBins,imageObsL(1,:),xvec,'linear'),200);
image_obs_distribution = xvec;
image_trunk_prob = yvec';
image_gap_prob = 1-image_trunk_prob;
plot(ax2,image_obs_distribution,image_trunk_prob,'r','linewidth',5)
plot(ax2,image_obs_distribution,image_gap_prob,'b--','linewidth',5);
% save(sprintf('temp-learnt-obs-pre-harvest-data%d-image.mat',datasetIter),'image_obs_distribution','image_trunk_prob','image_gap_prob');
