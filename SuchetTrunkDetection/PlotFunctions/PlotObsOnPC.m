function PlotObsOnPC(points2D,obs)
% Plot the observations on top of the flattened point cloud
figure('color','white')
plot(points2D(:,1),points2D(:,2),'.'); hold all;
axis equal;

% Plot the observation
% First rescale the Y-value
obs(:,2) = (obs(:,2)-min(obs(:,2)))/range(obs(:,2)) * range(points2D(:,2))*0.75;
plot(obs(:,1),obs(:,2),'r-','linewidth',3);
end