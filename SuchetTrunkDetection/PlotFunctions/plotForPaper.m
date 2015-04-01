% Plot graphs for the paper
%% emission graphs
close all
od = [0 10 200 220];
tr_prob = [0.1 0.25 0.8 0.8];
gp_prob = 1-tr_prob;

figure('color','white')
plot(od,tr_prob,'r-','linewidth',5)
hold on;
plot(od,gp_prob,'b--','linewidth',5)
xlabel('Number of pixels classified as trunk','FontSize',16)
ylim([0 1.05])
ylabel('Observation likelihood','FontSize',16)
h_legend = legend('Trunk','Gap/Row-end');
set(h_legend,'FontSize',16,'Position',[0.5604    0.7324    0.3411    0.1762])
title('State likelihood for image observations','FontSize',16);
xlim([0 max(od)])
strX = {'0','50','100','150','200','Max'};
set(gca,'XTick',[0 50 100 150 200 220],'XTickLabel',strX,'FontSize',16)


od = [0 0.2 0.4 0.5];
tr_prob = [0.02 0.1 0.65 0.65];
gp_prob = 1-tr_prob;

figure('color','white')
plot(od,tr_prob,'r-','linewidth',5)
hold on;
plot(od,gp_prob,'b--','linewidth',5)
xlabel('Fitted line length (m)','FontSize',16)
ylim([0 1.05])
ylabel('Observation likelihood','FontSize',16)
h_legend = legend('Trunk','Gap/Row-end');
set(h_legend,'FontSize',16,'Position',[0.5604    0.7324    0.3411    0.1762])
title('State likelihood for lidar observations','FontSize',16);
xlim([0 max(od)])
strX = {'0','0.1','0.2','0.3','0.4','Max'};
set(gca,'XTick',[0 0.1 0.2 0.3 0.4 0.5],'XTickLabel',strX,'FontSize',16)



mean_trunk_spacing = 1.5040;%1.5276; % Evaluated through ginput
std_trunk_spacing = 0.1551;%0.1722;
trunk_width = 0.1; % All units in metres
gaussianSpacing = [mean_trunk_spacing std_trunk_spacing]/0.05;
uniformDuration=2;
C = zeros(3,40);
C(1,1:uniformDuration(1)) = 1/uniformDuration(1); % Trunk duration
C(2,:) = gaussmf(1:40,fliplr(gaussianSpacing)); % Gap duration
C(3,1:end) = 1/40; % dummy_gap duration
Cx = (1:40)*0.05;
figure('color','white')
plot(Cx,C(1,:),'r-','linewidth',5);hold on;
plot(Cx,C(2,:),'b--','linewidth',5);hold on;
plot(Cx,C(3,:),'m-.','linewidth',5);hold on;
xlabel('Distance (m)','FontSize',16)
ylabel('Duration Probability','FontSize',16)
title('Duration probability for the V-trellis structure','FontSize',16)
h_legend = legend('Trunk','Gap','Row-end');
set(h_legend,'FontSize',16,'Position',[0.1508    0.7174    0.2232    0.1762])
set(gca,'FontSize',16)

return

od = [0 0.2 0.4 0.5];
tr_prob = [0.05 0.2 0.85 0.85];
gp_prob = [1 0.9 0.2 0.2];

strX = {'0','','','','','Max'};
figure('color','white')
plot(od,tr_prob,'r-','linewidth',5)
hold on;
plot(od,gp_prob,'b--','linewidth',5)
xlabel('Lidar observation (m) or image observation (pixel count)')
ylim([0 1.05])
ylabel('Observation likelihood')
h_legend = legend('Trunk','Gap/Row-end');
set(h_legend,'FontSize',16,'Position',[0.1408    0.7329    0.2232    0.1762])
title('State probability for a given observation');
set(gca,'XTick',[0 0.1 0.2 0.3 0.4 0.5],'XTickLabel',strX)



%% Plot tree face with results for pipeline
dataPath='X:\mantis-shrimp\processed\2014-03-31-melbourne-apples\2014-04-02-melbourne-apples\e8n-to-e2s\trunk-segmentation\row2\';
modelPath='X:\mantis-shrimp\processed\2014-03-31-melbourne-apples\2014-04-02-melbourne-apples\e8n-to-e2s\ladybug\images_cropped_undistorted_labels\training\';
d = bin_load([dataPath, 'treeFace.bin'],'d,d,d,ui,ui');
treeFace = d(:,1:3); treeFaceIDX = d(:,end-1); treeFaceTrunkCandidates = d(:,end);
load([dataPath,'segmentedTrunks.mat']);
obsX = obsTotal(:,1);

treeFaceFull = treeFace;
treeFace(treeFace(:,3)>4.5,:) = [];

xrange=[9.5 19];
selTreeFace = treeFace(treeFace(:,1)>xrange(1) & treeFace(:,1)<xrange(2),:);

figure('color','white')
plot(selTreeFace(1:1:end,1),selTreeFace(1:1:end,3),'.'); hold all;
axis equal;
hold on; 
L = statesImage2/max(statesImage2)*max(selTreeFace(:,3))*0.75;
plot(obsX,L,'r-','linewidth',2)
xlim(xrange); axis off

figure('color','white')
plot(selTreeFace(1:1:end,1),selTreeFace(1:1:end,3),'.'); hold all;
axis equal;
hold on; 
L = statesLaser2/max(statesLaser2)*max(selTreeFace(:,3))*0.75;
plot(obsX,L,'r-','linewidth',2)
xlim(xrange); axis off


figure('color','white')
plot(selTreeFace(1:1:end,1),selTreeFace(1:1:end,3),'.'); hold all;
axis equal;
hold on; 
L = obsImage(:,2)/max(obsImage(:,2))*max(selTreeFace(:,3))*0.75;
plot(obsX,L,'r-','linewidth',3);
xlim(xrange); axis off

figure('color','white')
plot(selTreeFace(1:1:end,1),selTreeFace(1:1:end,3),'.'); hold all;
axis equal;
hold on; 
L2 = obsLaser(:,2)/max(obsLaser(:,2))*max(selTreeFace(:,3))*0.75;
plot(obsX,L2,'r-','linewidth',3);
xlim(xrange); axis off

figure('color','white');
[linePos, lineEnds, lineLength, linePointsIDX] = LineFitObservations(treeFaceFull,0,'v-structure');
plot(selTreeFace(1:1:end,1),selTreeFace(1:1:end,3),'.'); hold all;
axis equal;
for k = 1:size(lineEnds,1)
    plot(lineEnds(k,[1 3]),lineEnds(k,[2 4]),'r-','linewidth',2)
end
xlim(xrange); axis off

figure('color','white')
plot(treeFaceFull(1:1:end,1),treeFaceFull(1:1:end,3),'.'); hold all;
axis equal
for i = 1:size(trunkIdxBottom,1)
    ids = trunkIdxBottom{i,2};
    plot(treeFaceFull(ids,1),treeFaceFull(ids,3),'ro');
end
xlim(xrange); axis off

% viewClusterWithImageV2(treeFaceFull(:,1),treeFaceFull(:,3),treeFaceTrunkCandidates,dataPath,modelPath,14.2)
% viewClusterWithImageV2(treeFaceFull(:,1),treeFaceFull(:,3),treeFaceTrunkCandidates,dataPath,modelPath,12.8)

figure('color','white')
plot(treeFaceFull(1:2:end,1),treeFaceFull(1:2:end,3),'.'); hold all;
axis equal;
hold on; 
L = obsImage(:,2)/max(obsImage(:,2))*max(selTreeFace(:,3))*0.75;
plot(obsX,L,'r-','linewidth',3);
xlim(xrange);

figure('color','white')
p1 = plot(selTreeFace(1:1:end,1),selTreeFace(1:1:end,3),'.'); hold all;
axis equal;
hold on; 
L = statesImage2/max(statesImage2)*max(selTreeFace(:,3))*0.75;
p2 = plot(obsX,L,'r-','linewidth',3);hold on;
L2 = statesLaser2/max(statesLaser2)*max(selTreeFace(:,3))*0.75;
p3 = plot(obsX,L2,'g--','linewidth',3);
xlim(xrange); axis off
legend([p2 p3],{'Image and Lidar','Lidar Only'},'FontSize',18)
