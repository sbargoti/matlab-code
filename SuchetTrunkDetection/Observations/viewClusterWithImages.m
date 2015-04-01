function viewClustersWithImage(x,y, xyClass, dataPath, xStart)
% function viewClustersWithImage(x,y, xyClass, dataPath)
% This function looks into the image folder also to give a neighbouring
% image file along with the point cloud cluster
% xStart takes the position in metres of which cluster to start at

% Initialise the point cloud figure
fh_pointCloud = figure('color','white');
ph = plot(0,0,'b.'); hold on;
phCluster = plot(0,0,'ro');
plotwidth = 5;
set(gca,'XDir','reverse')

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
        axis auto
        axis equal
        
        % Get the image
        laserToImageFile = [dataPath,'laser-to-camera\',num2str(uniqueClasses(i)),'.bin'];
        if exist(laserToImageFile)
            d=bin_load([dataPath,'laser-to-camera\',num2str(uniqueClasses(i)),'.bin'],'t,t,t,d,d,d,d,d,d,ui,ui');
            imageFileName = [seconds2iso(d(1,1)),'.undistorted.png'];
            img = imread([dataPath 'images\',imageFileName]);        
            classifiedImg = im2double(imread([dataPath 'images-classified\',imageFileName(1:end-3),'Prob.png']));
            trunkij = round(d(:,[4 5]));
            ClassificationRatePerCluster(img, trunkij, classifiedImg,fh_img);
            set(gca,'XLim',[300 900],'Ylim',[950 1400])
            set(fh_img,'units','normalized','outerposition',[0 0 1 1])
        else
            set(0,'currentfigure',fh_img)
            imshow('moon.tif');
        end
        
        keyboard
    end
end
    
