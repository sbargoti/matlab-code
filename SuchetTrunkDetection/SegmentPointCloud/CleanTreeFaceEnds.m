function pointsToClearIDX=CleanTreeFaceEnds(treeFace)
% Clear up low density points near the end of the row

% Get point distribution along the length of the row
slidingWidth = 0.5;
xWindows = min(treeFace(:,1)):slidingWidth:max(treeFace(:,1));
for i = 1:length(xWindows)-1
   points_in_window = treeFace(:,1)>xWindows(i) & treeFace(:,1)<xWindows(i+1); 
   pointCount(i) = sum(points_in_window);
end
medianPointCount = median(roundn(pointCount/2,2))*2; % Rounding to the nearest 200 then calc median

% Look near the last N% of the row to see if we are seeing garbage
minPtsThresh = 0.15*medianPointCount;
xMids = (xWindows(1:end-1)+xWindows(2:end))/2;
rowEdgeCheck = 0.15; % percent of row ends to check
startCheckPts = find(xMids < rowEdgeCheck*range(xMids)+min(xMids) & pointCount < minPtsThresh);
endCheckPts = find(xMids > -rowEdgeCheck*range(xMids)+max(xMids) & pointCount < minPtsThresh);
% Clear points in this section
startPos = -1;
endPos = 200;
if ~isempty(startCheckPts)
    startPos = xMids(startCheckPts(end));
    fprintf('Cleaning up the first %1.1f metres of the data\n',startPos);
end
if ~isempty(endCheckPts)
    endPos = xMids(endCheckPts(1));
    fprintf('Cleaning up the last %1.1f metres of the data\n',xMids(end)-endPos);
end
     
pointsToClearIDX = (treeFace(:,1)<startPos | treeFace(:,1)>endPos);
 