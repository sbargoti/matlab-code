function [imageObsL, pixelBins, lidarObsL, lengthBins] = observationModelStats(dataPath,analysisType,my_struct)
% using the ground truth data, and the developed observational mode,
% return the true relationship between the states and the observations
% input - analysisType, options: 'ground-truth','inference'
% my_struct - contains
% obsTotal,statesImage2,statesLaser2,obsYImage,obsYLidar, used when
% applying code withing the inference function - i.e. dont have accessed to
% the saved file yet. 

if nargin == 2
    % Load the results
    disp('Loading saved results')
    load([dataPath,'segmentedTrunks.mat']);
else
    if strcmp(analysisType,'ground-truth')
        load([dataPath,'segmentedTrunks.mat'],'gtPoints');
    end
    v2struct(my_struct);
end

% Split the ground truth data in the same bins as the observations slices
% in HSMM
obsX = obsTotal(:,1);
switch analysisType
    case 'ground-truth'
        % Check if ground truth data is available
        assert(logical(exist('gtPoints')),'Ground truth data doesnt exist here');
        % Gather true state values
        sliceEdges = [obsX(1)-(obsX(2)-obsX(1))/2;obsX(1:end)+[diff(obsX);obsX(2)-obsX(1)]/2];
        obsGT = DataToSlices(gtPoints(:,1),gtPoints(:,2),sliceEdges,'average');
        obsGT(obsGT(:,2)>0,2) = 1;
        % dialate the trunk observations by 1 on each side
        neighbouringStates = abs([diff(obsGT(:,2));0] + [0;diff(obsGT(:,2))]);
%         obsGT(:,2) = obsGT(:,2) +  neighbouringStates;
        obsGT(logical(neighbouringStates),:) = []; 
        obsYImage(logical(neighbouringStates)) = []; obsYLidar(logical(neighbouringStates)) = [];
        obsStatesI = obsGT(:,2);
        obsStatesL = obsGT(:,2);
    case 'inference'
        obsStatesI = statesImage2';
        obsStatesL = statesLaser2;
end
        
% Analyse image observations
% For trunks pick image observations where ther is a lidar return, as this is the only place where image analysis is done.
% tmpstates = obsStatesI;
% tmpobs = obsYImage;
% obsStatesI(obsYImage==0) = []; obsYImage(obsYImage==0) = [];
imageObs = obsYImage; 
pixelThreshold = 600; % like in the paper
imageObs(imageObs>pixelThreshold) = pixelThreshold;

% Generate observation likelihoods
pixelBins = 5:10:(pixelThreshold-5);
imageObsL(1,:) = hist(imageObs(obsStatesI==1),pixelBins); % for the trunks
% imageObs = tmpobs; obsStatesI = tmpstates;
% imageObs(imageObs>pixelThreshold) = pixelThreshold;
imageObsL(2,:) = hist(imageObs(obsStatesI==0),pixelBins); % for the gap states

% Analyse lidar observations
lidarObs = obsYLidar;
lengthThreshold = 0.5; % like in the paper
lidarObs(lidarObs>lengthThreshold) = lengthThreshold;

% Generate observation likelihoods
lengthBins = 0.01:0.02:(lengthThreshold-0.01);
lidarObsL(1,:) = hist(lidarObs(obsStatesL==1),lengthBins); % for the trunks
lidarObsL(2,:) = hist(lidarObs(obsStatesL==0),lengthBins); % for the trunks
