function ViewSegmentationResults(dataPath,modelPath)
% View results from a trunk segmentation pipeline
disp(dataPath)
d = bin_load([dataPath, 'treeFace.bin'],'d,d,d,ui,ui');
treeFace = d(:,1:3); treeFaceIDX = d(:,end-1); treeFaceTrunkCandidates = d(:,end);
load([dataPath,'segmentedTrunks.mat']);
obsX = obsTotal(:,1);

% treeFace(treeFace(:,3)>4.5,:) = [];
% keyboard
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,obsYLidar);
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,obsYImage);
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,obsTotal(:,2));
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,statesImage2');
% set(gcf,'Name','Trunk State estimates using Image and Laser Data');
% PlotLikelihoods([treeFace(:,1) treeFace(:,3)],obsX,statesLaser2');
% set(gcf,'Name','Trunk State estimates using Laser Data only');
% return
% keyboard
% viewClusterWithImageV2(treeFace(:,1),treeFace(:,3),treeFaceTrunkCandidates,dataPath,modelPath,102,0)
% return
if ~exist('gtPoints','var')
    figure('color','white');
    h_tf = plot(treeFace(:,1),treeFace(:,3),'.'); hold all;
    h_gt = plot(0,0,'ro','markerfacecolor','r','markersize',8);
    axis fill; axis equal
    slidingWidth = 10;
    slidingWith = range(treeFace(:,1))/round((range(treeFace(:,1))/slidingWidth));
    xWindows = min(treeFace(:,1)):slidingWidth:max(treeFace(:,1));
    xWindows = [xWindows(1:end-1);(xWindows(1:end-1)+xWindows(2:end))/2];
    xWindows = [xWindows(:);max(treeFace(:,1))];

    gtPoints = [];
    for i = 1:length(xWindows)-2
        xlim(xWindows(i:2:i+2))
        [gtPointsLocalX,gtPointsLocalY,button] = ginput;
        while button(end) == 2
            gtPoints(end,:) = [];
            set(h_gt,'Xdata',gtPoints(:,1),'Ydata',gtPoints(:,2))
            [gtPointsLocalX,gtPointsLocalY,button] = ginput;
        end
        while button(end)==3
            viewClusterWithImageV2(treeFace(:,1),treeFace(:,3),treeFaceTrunkCandidates,dataPath,modelPath,gtPointsLocalX(end),1)
            [gtPointsLocalX,gtPointsLocalY,button] = ginput;
        end
        gtPoints = [gtPoints; gtPointsLocalX gtPointsLocalY];
        set(h_gt,'Xdata',gtPoints(:,1),'Ydata',gtPoints(:,2))
    end
    save([dataPath,'segmentedTrunks.mat'],'gtPoints','-append');
end

fprintf('Evaluating results from image and laser analysis\n')
EvaluateAccuracy(gtPoints,cell2mat(trunkIdxBottom(:,1)),treeFace);
fprintf('Evaluating results from laser analysis only\n')
EvaluateAccuracy(gtPoints,cell2mat(trunkIdxBottomLaser(:,1)),treeFace);


    
