function [frontFacePC,pcIdx] = SplitVStructure(points3D)
% function frontFacePC = SplitVStructure(PC)
% Given a point cloud post ground removal, separate out the V structure
disp('Splitting the V Structure');
PC = points3D;
% Cut off the top 20% of the point cloud - gets rid of the roof
% Cut the roof from the experiemntal data
zrange = range(PC(:,3));
topcut = min(PC(:,3))+zrange*0.2;
topcutLogical = PC(:,3) < topcut;
topcutLogical = PC(:,3) < -2;
topremovedIdx = find(~topcutLogical);
PC(topcutLogical,:) = [];
bottomcutLogical = PC(:,3) > -0.6;
PC(bottomcutLogical,:) = [];
% Cut the roof from the point cloud
topcutLogical = points3D(:,3) < (min(points3D(:,3)+0.5));
topremovedIdx = find(~topcutLogical);
points3D(topcutLogical,:) = [];

% Sliding window along the x axis
slidingWidth = 2;
xWindows = min(PC(:,1)):slidingWidth:max(PC(:,1));
xWindows = linspace(min(PC(:,1)),max(PC(:,1)),length(xWindows));


% Go through each window and figure out the separation location between the V faces
failedGMM = 0;
figure('color','white');ph1 = plot(0,0,'-','linewidth',2);
hold on; 
% ph2 = plot(0,0,'go','markerfacecolor','green');
ph4 = plot(0,0,'k--','linewidth',3);
ph3 = plot(0,0,'ro','markerfacecolor','red', 'MarkerSize', 12);
ylabel('% points per depth bin'); title('Point distribution along the depth of a particular slice');
xlabel('y (m)')
legend([ph1,ph4,ph3],{'Point distribution','Gaussian Fit','Mid Point'});
for i = 1:length(xWindows)-1
    % Points that lie in this window
    points_in_window = PC(:,1)>xWindows(i) & PC(:,1)<xWindows(i+1);
    xSlice(i) = (xWindows(i) + xWindows(i+1))/2;
    
    % Histogram distribution along the y axis
    [N,Y] = hist(PC(points_in_window,2),30);
    pointCount = N/sum(N)*100;
    
    % Split the data into two - thus spliting the V face for the current
    % window
    if sum(points_in_window)<10
        gradientBoundaryPoint(i) = nan;
        boundaryPoint(i) = nan;
        continue;
    end
    try,    gradientBoundaryPoint(i) = SplitSlice(pointCount,Y);catch,keyboard;end
    
    % Get intial estimates for the univariate gaussian fits
    if i==1 || failedGMM ==1 
        % Use this as an initial guess for the first gaussian mixture fit
        S.mu = [gradientBoundaryPoint(i)-0.5;gradientBoundaryPoint(i)+0.5];
        S.Sigma(1,1,1) = 0.5;
        S.Sigma(1,1,2) = 0.5;
        S.PComponents = [0.8,0.2];
    else
        % Otherwise just use the previous windows estimate
        S.mu = gm.mu;
        S.Sigma = gm.Sigma;
        S.PComponents = [0.7,0.3];
    end

    % Fit two gaussians onto the data
    try
        gm = gmdistribution.fit(PC(points_in_window,2),2,'Start',S);
        % The Boundary point is assumed to be half way between the two peaks
        boundaryPoint(i) = mean(gm.mu);
        failedGMM = 0;
    catch
        boundaryPoint(i) = gradientBoundaryPoint(i);
        failedGMM = 1;
    end
    
    set(ph1,'Xdata',Y,'Ydata',pointCount);
%     set(ph2,'Xdata',Y(gradientBoundaryPoint(i)==Y),'Ydata',pointCount(gradientBoundaryPoint(i)==Y))
    if ~failedGMM
        gausX = linspace(min(Y),max(Y),50)';
        gausY = pdf(gm,gausX)./max(pdf(gm,gausX))*max(pointCount);
        set(ph4,'Xdata',gausX,'Ydata',gausY);
        set(ph3,'Xdata',boundaryPoint(i),'Ydata',interp1(gausX,gausY,boundaryPoint(i)))
    else
        set(ph3,'Xdata',boundaryPoint(i),'Ydata',interp1(Y,pointCount,boundaryPoint(i)))
    end
    if i == 14
    keyboard;
    end
end

% Plot for paper:
% datapath = 'X:\mantis-shrimp\processed\2014-03-31-melbourne-apples\2014-04-02-melbourne-apples\e8n-to-e2s\trunk-segmentation\row2\ '
% i = 14;

% Apply a smoothing filter to the boundary points
smoothingWindow = 10; % in metres
smoothBoundary = smooth(xSlice,boundaryPoint,round((smoothingWindow/range(xWindows))*length(xSlice)),'rloess')+0.1;
smoothBoundary = boundaryPoint;

% Plot the separation line
figure('color','white')
plot(points3D(:,1),points3D(:,2),'.'); axis equal; hold on;
plot(xSlice,smoothBoundary,'r-','linewidth',5)
legend('Point Cloud','Boundary line')

% Interpolate PC point values are this boundary
interpVals = interp1(xSlice,smoothBoundary,points3D(:,1),'linear','extrap');

% Section point cloud depending on which side of the boundary the point
% lies in
fronthalfLogical = points3D(:,2)<interpVals;
fronthalfIdx = find(fronthalfLogical);
frontFacePC = points3D(fronthalfLogical,:);

% Rotate points in order to make the trees stand up straight
% frontFacePC = StraightenFace(frontFacePC,mean(smoothBoundary));
abovegroundlogical = ~(frontFacePC(:,3)>0);
pcIdx = topremovedIdx(fronthalfIdx(abovegroundlogical));
frontFacePC(~abovegroundlogical,:) = [];

% Shift back down
frontFacePC(:,3) = frontFacePC(:,3)-max(frontFacePC(:,3));

function cutPoint = SplitSlice(N,X) 
% This function is currently a temporary hack, need to think of a better
% way

% Change in point counts giving rise to locations of positive gradient
change_in_N = diff(N);
positiveGradient = find(change_in_N>=0);

% Threshold cut off - HACK
belowThreshold = find(N<5);

% Find points that have a positive gradient and are below the set threshold
satisfactoryPoints = intersect(positiveGradient,belowThreshold);

% Find the first point that occurs after the maximum peak - and make sure
% the  maximum peak is in the first 60% of the data
[~,argmaxN] = max(N);
while argmaxN/length(N) > 0.5
    N(argmaxN) = N(argmaxN) - 10;
    [~,argmaxN] = max(N);
end
cutPointIdx = find(satisfactoryPoints>=argmaxN);
if ~length(cutPointIdx)
    cutPoint = X(round(length(X)*0.4));
else
    cutPointIdx = satisfactoryPoints(cutPointIdx(1));
    cutPoint = X(cutPointIdx);
end

function PCVertical = StraightenFace(PCSlanted,meanY)
% once the V structure has been split, take one side and turn it such that
% it stands vertically.

% Take a smaller sample to fit the plane onto
xyzSample = PCSlanted(1:10:end,:);

% fit RANSAC plane
[Bfitted, ~, ~] = ransacfitplane(xyzSample', 0.15, 0);

% Angular offset
YZ_offset = atan(Bfitted(3)/Bfitted(2));

% Rotate PC
PCVertical = PCSlanted*angle2dcm(0,0,YZ_offset);

% Find the zoffset and shift such that the bottom are the trunks are at z=0
zoffset = [0,meanY,0]*angle2dcm(0,0,YZ_offset);
PCVertical(:,3) = PCVertical(:,3) - zoffset(3);

%% DEBUG CODE
% % Go through each window and figure out the separation location between the V faces
% % figure('color','white');ph1 = plot(0,0,'-');
% % hold on; ph2 = plot(0,0,'ro','markerfacecolor','red');
% % ph3 = plot(0,0,'go','markerfacecolor','green');
% for i = 1:length(xWindows)-1
%     % Points that lie in this window
%     points_in_window = PC(:,1)>xWindows(i) & PC(:,1)<xWindows(i+1);
%     
%     % Histogram distribution along the y axis
%     [N,Y] = hist(PC(points_in_window,2),30);
%     pointCount = N/sum(N)*100;
%     
%     
%     % Split the data into two - thus spliting the V face for the current
%     % window
%     boundaryPoint(i) = SplitSlice(pointCount,Y);
%     xSlice(i) = (xWindows(i) + xWindows(i+1))/2;
% %     disp(xSlice(i))
%     
%     
%         if i==1
%         S.mu = [boundaryPoint(i)-0.5;boundaryPoint(i)+0.5];
%         S.Sigma(1,1,1) = 0.5;
%         S.Sigma(1,1,2) = 0.5;
%         S.PComponents = [0.8,0.2];
%     else
%         S.mu = gm.mu;
%         S.Sigma = gm.Sigma;
%         S.PComponents = [0.7,0.3];
%     end
%     % Fit Two Gaussians
% %     try
%     gm = gmdistribution.fit(PC(points_in_window,2),2,'Start',S);
% %     catch
% %         keyboard;
% %     end
% %     fprintf('Mean: %f,%f\n',gm.mu)
% %     fprintf('Variance: %f,%f\n',gm.Sigma(1,1,1),gm.Sigma(1,1,2))
% %     fprintf('Weights: %f,%f\n',gm.PComponents)
%     % Find centre point
%     boundaryPoint2(i) = mean(gm.mu);
%     boundaryPoint2Y = interp1(Y,pointCount,boundaryPoint2(i));
% %     if i > 150
% % %         keyboard;
% %     end
% %     if xSlice(i) < 68 && xSlice(i) > 58
% %         set(ph1,'Xdata',Y,'Ydata',pointCount);
% %         set(ph2,'Xdata',Y(boundaryPoint(i)==Y),'Ydata',pointCount(boundaryPoint(i)==Y))
% %         set(ph3,'Xdata',boundaryPoint2(i),'Ydata',boundaryPoint2Y)
% %         keyboard;
% %     end
% end
%%%%%%%%%%% Plot a particular slice and GMM fits
% figure('color','white');ph = plot(Y,pointCount)
% hold on;
% x = [2.5:0.05:5]';
% y1 = gm.PComponents(1)*mvnpdf(x,gm.mu(1),gm.Sigma(1,1,1));
% y2 = gm.PComponents(2)*mvnpdf(x,gm.mu(2),gm.Sigma(1,1,2));
% y = 8*(y1+y2);
% plot(x,y,'g-','linewidth',2)
% plot(boundaryPoint(i),interp1(Y,pointCount,boundaryPoint(i)),'ro','markerfacecolor','red')
% legend('Point distribution','Gaussian Fit','Mid Point')
% xlabel('y (m)')
% ylabel('% points per depth bin')
% title('Point distribution along the depth of a particular slice')
    