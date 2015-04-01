function [nonGroundPC,nonGroundPCIdx,groundPC,groundPCIdx] = GroundRemovalThresholdWindow(points3D,variance)
% function nonGroundPC,nonGroundPCIdx,groundPC,groundPCIdx] = GroundRemovalThresholdWindow(PC,variance)
% Uses a window approash instead of total scan

disp('Removing Ground')

% Sliding window along the x axis
slidingWidth = 5; % needs to be much larger than separation between trees
xWindows = min(points3D(:,1)):slidingWidth:max(points3D(:,1));
xWindows = linspace(min(points3D(:,1)),max(points3D(:,1)),length(xWindows));

% Initialise points th
nonGroundPCLogical = zeros(size(points3D,1),1);

% Only look at the bottom half of the histogram when analysing (so we don't
% get confused by the top being part of the ground
groundLim = max(points3D(:,3));
searchThresh = groundLim - range(points3D(:,3))*0.4;

for i = 1:length(xWindows)-1
    % Points that lie in this window
    points_in_window = points3D(:,1)>xWindows(i) & points3D(:,1)<xWindows(i+1);

    % Find the distribution of points along the z axis - the roof and the
    % ground should be the peaks, If they arent... tough cookies
    [pointsAtHeight,height] = hist(points3D(points_in_window,3),100);
    
    % Cull points on the upper half of the apples trees
    pointsAtHeight = pointsAtHeight(height>searchThresh);
    height = height(height>searchThresh);
%     keyboard
    % Find peaks
    [~,sortOrder] = sort(pointsAtHeight,'descend');
    groundHeight = height(sortOrder(1));
    
    % Cut off all points with a below grond and a certain variance above it too
%     variance = 0.15;
    nonGroundPCLogical(points_in_window) = points3D(points_in_window,3)<(groundHeight-variance);
end


nonGroundPC = points3D(logical(nonGroundPCLogical),:);
groundPC = points3D(~nonGroundPCLogical,:);
nonGroundPCIdx = find(nonGroundPCLogical);
groundPCIdx = find(~nonGroundPCLogical);

% plotting the ground removal process for a paper
% figure('color','white')
% p1 = plot(ppclean(:,1),-ppclean(:,2),'k.','markersize',1)
% hold on;
% hp = pointsAtHeight;hp = hp/max(hp)*1.2;hp = -hp + 0.7;
% p2 =  plot(hp,-height,'linewidth',3);
% title('Point density based ground removal')%,'FontSize',14)
% ylabel('Height (m)')%,'FontSize',14)
% xlabel('Distance into V-Structure (m)')%,'FontSize',14)
% xlim([-1 5])
% axis equal
% h1 = legend(p2,'Point Density');
% % set(h1,'FontSize',14)
