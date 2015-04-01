function viewClusterWithImageV2(x,y, xyClass, dataPath, modelPath, xStart,pointOnly)
% function viewClusterWithImageV2(x,y, xyClass, dataPath)
% This function looks into the image folder also to give a neighbouring
% image file along with the point cloud cluster
% xStart takes the position in metres of which cluster to start at
% Similar to viewClusterWithImage but now doesn't require pre classified
% images

% Initialise the point cloud figure
fh_pointCloud = figure('color','white');
ph = plot(0,0,'b.'); hold on;
phCluster = plot(0,0,'ro');
plotwidth = 5;
axis equal
axis auto
% set(gca,'XDir','reverse')

% Load data and add paths
fprintf('Path containing trained classification models \n %s \n',modelPath);
load([modelPath 'sae1OptThetaRGB.mat']);
load([modelPath 'stackedRelatedParaRGB.mat']);
load([modelPath 'stackedAEOptThetaRGB.mat']);
load([modelPath 'saeRelatedParaRGB.mat']);
classFcnPath = 'D:\Code\matlab\multClassImgSeg\';
fprintf('Path containing Calvins classification code \n %s \n', classFcnPath);
addpath( [classFcnPath 'code\Projects\multiClassImageSeg'] );
addpath( [classFcnPath 'code\Projects\multiClassImageSeg\suchetFunctions'] );
addpath( [classFcnPath 'code/UFLDL/code/' 'multiScaleUFL'] )% for vec_white_image
addpath( [classFcnPath 'code/UFLDL/code/' 'stackedae'] )% for stackedAEPredict
addpath( [classFcnPath 'code/UFLDL/code/' 'stl'] ) % for feed forward auto encoder

% make sure 0 is not a cluster
uniqueClasses = unique(xyClass);
uniqueClasses(uniqueClasses==0) = []; % Make sure zero is not a class

% sort clusters according to their position on the data
clusterXPos = zeros(length(uniqueClasses),1);
for i = 1:length(uniqueClasses)
    xClusters = x(xyClass==uniqueClasses(i));
    clusterXPos(i) = mean(xClusters);
end
[~,sortOrder] = sort(clusterXPos);
uniqueClasses = uniqueClasses(sortOrder);

% Initilaise the image figure
fh_img = figure('color','white');

for i = 1:length(uniqueClasses)
    uniqueClasses(i)
    xClusters = x(xyClass==uniqueClasses(i));
    yClusters = y(xyClass==uniqueClasses(i));
    meanX = mean(xClusters);
    
    if meanX < xStart
        continue
    else
        % Draw the plot
        xdraw = x(x<meanX+plotwidth & x>meanX-plotwidth);
        ydraw = y(x<meanX+plotwidth & x>meanX-plotwidth);
        set(ph,'Xdata',xdraw,'Ydata',ydraw);
        set(phCluster, 'Xdata',xClusters, 'Ydata',yClusters);
        
        % Get the image
        laserToImageFile = [dataPath,'laser-to-camera\',num2str(uniqueClasses(i)),'.bin'];
        if exist(laserToImageFile)
            d=bin_load([dataPath,'laser-to-camera\',num2str(uniqueClasses(i)),'.bin'],'t,t,t,d,d,d,d,d,d,ui,ui');
            imageFileName = [seconds2iso(d(1,1)),'.undistorted.png'];
            img = imread([dataPath 'images\',imageFileName]);        
            trunkij = round(d(:,[4 5]));
            % Make sure the image points are within range
            prevSize = size(trunkij,1);
            trunkij(trunkij(:,2)>size(img,1),:)=[]; trunkij(trunkij(:,2)<1,:)=[];
            trunkij(trunkij(:,1)>size(img,2),:)=[]; trunkij(trunkij(:,1)<1,:)=[];
            ClassificationRatePixel(img, trunkij, fh_img,  meanPatch, ZCAWhite, stackedAEOptTheta, numClasses, netconfig);
%             set(gca,'XLim',[300 900],'Ylim',[950 1400])
%             set(fh_img,'units','normalized','outerposition',[0 0 1 1])
        else
            set(0,'currentfigure',fh_img)
            imshow('moon.tif');
        end
        if pointOnly % exit the function if we only want to have a look at one value
            close(fh_img)
            close(fh_pointCloud)
            return
        end
%         keyboard
    end
end
    
