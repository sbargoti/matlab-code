function [AlignedPC,PCIdx,OriginalPC,originalPCTime] = RealignRow(CSVFileName)

% Import data
[Time,r,b,e,x,y,z,ref,scan] = ImportSickCSV(CSVFileName);
p = findstr(CSVFileName,'SickRow');
[originalPCTime,r,b,e,x2,y2,z2,ref,scan] = ImportSickCSV([CSVFileName(1:p+6),'Z',CSVFileName(p+7:end)]);
OriginalPC = [x2,y2,z2];

% Rotate Data along dominant axes
% RotatedRow = rotateAlong1D_PCA([x,y,z]);
RotatedRow = rotateAlong1D_polyfit([x,y,z]);

% Align ground with xyplane
[AlignedPC,PCIdx] = AlignMajorPlane(RotatedRow);


function rotatedXYZ = rotateAlong1D_polyfit(xyz)
% functino rotatedxyz = rotateAlong1D(xyz)
% a line fit on the entire data, rotate it

% Take polyfit
ws = warning('off','all');  % Turn off warning
P = polyfit(xyz(1:100:end,1),xyz(1:100:end,2),1);
warning(ws)

% Rotation angle
rot_angle = atan(P(1));

% Rotation matrix
rot_mat = angle2dcm(-rot_angle,0,0);

% Rotate points
rotatedXYZ = xyz*rot_mat;

% Shift x and y axes
rotatedXYZ(:,1) = max(rotatedXYZ(:,1)) - rotatedXYZ(:,1); 
rotatedXYZ(:,2) = max(rotatedXYZ(:,2)) - rotatedXYZ(:,2); 


function rotatedXYZ = rotateAlong1D_PCA(xyz)
% functino rotatedxyz = rotateAlong1D(xyz)
% using PCA, realign data


% reduced_points = xyz(1:50:size(xyz,1));
points_centreshift = bsxfun(@minus, xyz, mean(xyz,1));

% Covariance
Covaraince = cov(points_centreshift);

% Eigen decomposition
[V,D] = eig(Covaraince);

% Order eigen values in descending order
[~,Eorder] = sort(diag(D),'descend');

% Disable any transformation in z
V_ordered = V(:,Eorder);
V_ordered(:,end) = [0;0;1];

% Align along major axis
rotatedXYZ = xyz*V_ordered;



function [alignedXYZ,alignedXYZIdx] = AlignMajorPlane(xyz)

% Flip the Y direction - changes depending on going downhill/uphill
alignedXYZ = fixYDir(xyz);

% Shift down such that ground is at z = 0;
% z_loc = mean(P,2)'*rotation_matrix(:,3);
% alignedXYZ(:,3) = alignedXYZ(:,3)-z_loc;
alignedXYZ(:,3) = alignedXYZ(:,3)-max(alignedXYZ(:,3));

% Shift that the closest point is at y = 0
% alignedXYZ(:,2) = alignedXYZ(:,2)-min(alignedXYZ(:,2));
alignedXYZ(:,2) = alignedXYZ(:,2)-min(alignedXYZ(:,2));

% Cut off points more than a certain distance away
[alignedXYZ,alignedXYZIdx] = cutVStructure(alignedXYZ);
% alignedXYZ(alignedXYZ(:,2)>3.7,:) = [];

% Shift x axis to start at 0
alignedXYZ(:,1) = alignedXYZ(:,1)-min(alignedXYZ(:,1));

% take smaller sample for rotation
xyz_sample = alignedXYZ(alignedXYZ(:,3) > -1,:);

% fit RANSAC plane
[Bfitted, ~, ~] = ransacfitplane(xyz_sample(1:300:end,:)', 0.05, 0);

% Rotate towards xyplane
xy_offset = atan(Bfitted(2)/Bfitted(3));
% rotation_matrix = angle2dcm(0,0,xy_offset+pi);
rotation_matrix = angle2dcm(0,0,xy_offset);
alignedXYZ = alignedXYZ*rotation_matrix;

% Translate again
alignedXYZ(:,3) = alignedXYZ(:,3)-max(alignedXYZ(:,3));
alignedXYZ(:,2) = alignedXYZ(:,2)-min(alignedXYZ(:,2));


function xyz = fixYDir(xyz)
% Find the distrubution of points long y (more points if closer to vehicle)
[a,~] = hist(xyz(:,2));
[~,maxLoc] = max(a);

if maxLoc/length(a) > 0.5
    % if the majority of points are further awaay from the 0-y, the flip
    % Ydir
    xyz(:,2) = -(xyz(:,2) - max(xyz(:,2)));
else
    % Do nothing
end

function [closestV,closestVIdx] = cutVStructure(xyz)
% Go across the x direction in slices and cut off at certain places. 

points3D = xyz;
maxY = max(points3D(:,2));

% Sliding windows
slidingWidth = 3;
xWindows = min(xyz(:,1)):slidingWidth:max(xyz(:,1));
xyz = xyz(xyz(:,3) < -1 & xyz(:,3) > -3.5,:);
% figure('color','white');
% p1 = plot(0,0);

for i = 1:length(xWindows)-1
    points_in_window = xyz(:,1)>xWindows(i) & xyz(:,1)<xWindows(i+1);
    xSlice(i) = (xWindows(i) + xWindows(i+1))/2;
    
    % Histogram distribution along the y axis
    [N,Y] = hist(xyz(points_in_window,2),30);
    pointCount = [];
    pointCount = N/sum(N)*100;
    % Pad the data such that Y spans to the maximum Y in the point cloud
    pointCount = [pointCount zeros(1,length(Y(end):Y(2)-Y(1):maxY))];
    Y = [Y Y(end):Y(2)-Y(1):maxY];
    
    % Find areas where no points exist
    pointCount(pointCount < 0.5) = 0;
    trippleDiff = diff(diff(diff(pointCount)));%
    noPoints = find(trippleDiff==0);

    while noPoints(1) < 0.3*length(pointCount)
        noPoints(1) = [];
    end
    boundaryPoint(i) = Y(noPoints(1)+2);
    
%     set(p1,'Xdata',Y,'Ydata',pointCount);
end

figure('color','white')
plot(points3D(:,1),points3D(:,2),'.'); axis equal; hold on;
plot(xSlice,boundaryPoint,'r-')

% Interpolate PC point values are this boundary
interpVals = interp1(xSlice,boundaryPoint,points3D(:,1),'linear','extrap');

% Section point cloud depending on which side of the boundary the point
% lies in
closestVLogical = points3D(:,2)<interpVals;
closestVIdx = find(closestVLogical);
closestV = points3D(closestVLogical,:);


