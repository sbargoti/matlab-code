function viewTreeFaceOnBackground(x,y,z,treeFaceIDX)
% Plot function to view the tree face in a different colour

fh = figure('color','white');

% Get the two point cloud
pc = [x,y,z];
pcNotFace = pc(setdiff(1:length(x),treeFaceIDX),:);
pcFace = pc(treeFaceIDX,:);

% Thin down points less than z = 0; (higher up points)
uppoints = find(pcFace(:,3)<0);
pcFace(uppoints(1:2:end),:) = [];
uppoints = find(pcNotFace(:,3)<0);
pcNotFace(uppoints(1:2:end),:) = [];

% plot
plot3(pcFace(:,1),pcFace(:,2),pcFace(:,3),'.');
set(gca,'Zdir','reverse');
axis equal
axis vis3d
hold on;
plot3(pcNotFace(:,1),pcNotFace(:,2),pcNotFace(:,3),'r.');
