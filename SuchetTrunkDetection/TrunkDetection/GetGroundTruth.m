function GetGroundTruth(dataPath,modelPath)
% simlar to the ground truth code in viewsegmentationresults
% can now get ground truth without waiting for the trunkSegmentationPart2
% to complete

disp(dataPath)
d = bin_load([dataPath, 'treeFace.bin'],'d,d,d,ui,ui');
treeFace = d(:,1:3); treeFaceIDX = d(:,end-1); treeFaceTrunkCandidates = d(:,end);
fprintf('treeFace Xrange: %2.2f\n',range(treeFace(:,1)));

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
if exist([dataPath,'segmentedTrunks.mat'],'file')
    save([dataPath,'segmentedTrunks.mat'],'gtPoints','-append');
else
    save([dataPath,'segmentedTrunks.mat'],'gtPoints');
end
fprintf('Total number of trees = %d\n',size(gtPoints,1));
