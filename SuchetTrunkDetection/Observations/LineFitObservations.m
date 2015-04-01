function [linePos, lineEnds, lineLength, linePointsIDX] = LineFitObservations(treeFace,plot_on,row_type)
% function [linePos, lineEnds, lineLength, linePointsIDX] = LineFitObservations(treeFace,plot_on)
% Fits points to the bottom of the pointcloud - treeFace. 
% the linePointsIDX are wrt to the input point cloud

% The trunks are only present in the bottom part of the point cloud, so we
% shall only need to work with this part
cropHeight = 0.5; % in metres
pcBottomIdx = find(treeFace(:,3)<cropHeight);
pcBottom = treeFace(pcBottomIdx,:);

% Apply hough transformation to fit lines to onto the tree trunks.
points2D = [pcBottom(:,1) pcBottom(:,3)];
[linePos, lineEnds, lineLength, ~, linePointsBottomIdx] = HoughLineFit(points2D,row_type);
linePointsIDX = cellfun(@(x) pcBottomIdx(x)', linePointsBottomIdx,'UniformOutput',false);


% Plot the lines on the flattened point cloud data
if plot_on
    skipper = 2;
    figure('color','white')
    plot(treeFace(1:skipper:end,1),treeFace(1:skipper:end,3),'.'); hold all;
    axis equal;
    
    % Go through each line and plot onto the graph
    for k = 1:size(lineEnds,1)
        plot(lineEnds(k,[1 3]),lineEnds(k,[2 4]),'r-','linewidth',2)
    end
end