function [nonGroundPC,nonGroundPCIdx,groundPC,groundPCIdx] = GroundRemovalThreshold(points3D)
% function nonGroundPC,nonGroundPCIdx,groundPC,groundPCIdx] = GroundRemovalThreshold(PC)
disp('Removing Ground')

% Find the distribution of points along the z axis - the roof and the
% ground should be the peaks, If they arent... tough cookies
[pointsAtHeight,height] = hist(points3D(:,3),100);

% Find peaks
[~,sortOrder] = sort(pointsAtHeight,'descend');
groundHeight = height(sortOrder(1));

% Cut off all points with a below grond and a certain variance above it too
variance = 0.2;
nonGroundPCLogical = points3D(:,3)<(groundHeight-variance);
nonGroundPC = points3D(nonGroundPCLogical,:);
groundPC = points3D(~nonGroundPCLogical,:);
nonGroundPCIdx = find(nonGroundPCLogical);
groundPCIdx = find(~nonGroundPCLogical);
