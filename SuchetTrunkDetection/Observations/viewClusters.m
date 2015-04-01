function viewClusters(x,y, xyClass)

% make sure 0 is not a cluster
figure('color','white');
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

ph = plot(0,0,'b.'); hold on;
phCluster = plot(0,0,'ro');
plotwidth = 5;
for i = 1:length(uniqueClasses)
    uniqueClasses(i)
    xClusters = x(xyClass==uniqueClasses(i));
    yClusters = y(xyClass==uniqueClasses(i));
    meanX = mean(xClusters);
    xdraw = x(x<meanX+plotwidth & x>meanX-plotwidth);
    ydraw = y(x<meanX+plotwidth & x>meanX-plotwidth);
    set(ph,'Xdata',xdraw,'Ydata',ydraw);
    set(phCluster, 'Xdata',xClusters, 'Ydata',yClusters);
    axis auto
    axis equal
    keyboard
end
    
