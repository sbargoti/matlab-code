function [treeFace,treeFaceIDX] = ExtractTreeFace(points3D,structureType)
% function [treeFace,treeFaceIDX] = ExtractTreeFace(points3D,structureType)
% Extract the closest tree face from the apple farm data
%
% Input:
% points3D   -   a nx3 vector
% structureType - string - either 'v-stucture' or 'i-structure'
%
% Output:
% treeFace - nx3 vector of just the closest tree face
% treeFaceIDX - corresponding index values from the original point cloud

% % Delete noisy points (found in some of the data sets...)
% validIDX = find(points3D(:,3)> -4 & points3D(:,3) < 2);
% points3D = points3D(validIDX,:);

% Realign the point cloud such that the row is along the y-direction
[pointsRow,pointsRowIDX] = RealignRowV2(points3D(:,1),points3D(:,2),points3D(:,3),structureType);

% Perform threshold based ground removal
% [nonGroundPts,ngpIdx,~,~] = GroundRemovalThreshold(pointsRow);
% Need to test the following function with the next row
variance = 0.1; % variance = 0.15 for the october trials
[nonGroundPts,ngpIdx,~,~] = GroundRemovalThresholdWindow(pointsRow,variance);
% viewTreeFaceOnBackground(pointsRow(:,1),pointsRow(:,2),pointsRow(:,3),ngpIdx);

% If Dealing with a v-structure, need to split it up
switch structureType
    case 'v-structure'
        [treeFace,localTreeFaceIDX] = SplitVStructure(nonGroundPts);
    case 'i-structure'
        treeFace = nonGroundPts;
        localTreeFaceIDX = 1:length(ngpIdx);
        % Shift the points down
        treeFace(:,3) = treeFace(:,3)-max(treeFace(:,3));
end

% Clear up low density points near the end of the row
is_TBLOCK = 0; %The low density clean up doesnt work on the March2013 T-block method as the point cloud density is low throughout the row (missing tree mids)
if ~is_TBLOCK
    pointsToCleanIDX=CleanTreeFaceEnds(treeFace);
    treeFace(pointsToCleanIDX,:) = [];
    localTreeFaceIDX(pointsToCleanIDX) = [];
    fprintf('%2.2f meters cleaned from the start\n',min(treeFace(:,1))-min(nonGroundPts(:,1)))
    fprintf('%2.2f meters cleaned from the end\n',-max(treeFace(:,1))+max(nonGroundPts(:,1)))
else
    fprintf('Operating in T-block from the March 2013 field trial, faulty sick data\n')
end

% Map the idx back to the input vector
% treeFaceIDX = validIDX(pointsRowIDX(ngpIdx(localTreeFaceIDX)));
treeFaceIDX = pointsRowIDX(ngpIdx(localTreeFaceIDX));

