% Main function for trunk detection using images
% In its current form, it jumps between linux scripts and matlab functions
% clear all; close all; clc;
function trunkSegmentationPart1(dataPath,row_number,row_type)
%% Load point cloud data - both original and rotated/flattened [preprocessing done in linux]
% parentFolder = {['X:\mantis-shrimp\processed\',...
%     '2014-03-31-melbourne-apples\2014-04-02-melbourne-apples\'];
%     ['X:\mantis-shrimp\processed\',...
%     '2013-10-08-melbourne-apples-processed\shrimp\']};
% log_name = {'e8n-to-e2s';'e8-3-v-rows';'e22-e6-d20-d14-slow'};
% row_number = 2;
% dataPath = [parentFolder{1}, log_name{1}, ...
%     '\trunk-segmentation\row', num2str(row_number),'\'];
fprintf('Data Path is: \n %s \n',dataPath);
d0=bin_load([dataPath,'row',num2str(row_number), '_Z0.bin'],'t,d,d,d,ui');
x = d0(:,2); y = d0(:,3); z = d0(:,4);
d=bin_load([dataPath,'row', num2str(row_number), '_Z.bin'],'t,d,d,d,ui');
% x2 = d(:,2); y2 = d(:,3); z2 = d(:,4);

% Set output folder for any results
outputFolder = dataPath;

%% Extract the front face from the data
[treeFace,treeFaceIDX] = ExtractTreeFace([x,y,z],row_type);
% Reverse the z axis such that z points upwards (easier to visualise)
treeFace(:,3) = -treeFace(:,3);
viewTreeFaceOnBackground(x,y,z,treeFaceIDX);

return

%% Perform Hough Transform to get line fit observations
[linePos, lineEnds, lineLength, linePointsIDX] = LineFitObservations(treeFace,1,row_type);

%% Extract clusters based on the points extracted from the line fitting
max_clusters = 1800; min_points_per_cluster = 10;
treeFaceTrunkCandidates = zeros(size(treeFace(:,1)));
treeFaceTrunkCandidates = ExtractClusters(linePos(:,1),linePointsIDX,...
    treeFaceTrunkCandidates,max_clusters,min_points_per_cluster,...
    0);
% Cut off the tree face near the ends
max_edge=0.5; % Spacing before the first observation
low_cut = treeFace(:,1) < min(treeFace(treeFaceTrunkCandidates~=0,1))-max_edge;
hi_cut = treeFace(:,1) > max(treeFace(treeFaceTrunkCandidates~=0,1))+max_edge;
treeFaceIDX(low_cut | hi_cut ) = [];
treeFaceTrunkCandidates(low_cut | hi_cut ) = [];
treeFace(low_cut | hi_cut ,:) = [];
fprintf('Row length: %2.2f\n',range(treeFace(:,1)));

% View clusters if needed
% viewClusters(treeFace(:,1),treeFace(:,3),treeFaceTrunkCandidates)
% keyboard
%% Save clusters for mapping to images in linux
trunkCandidates = zeros(size(x));
trunkCandidates(treeFaceIDX) = treeFaceTrunkCandidates; 
% Save the trunk candidates
bin_save_local([d(trunkCandidates~=0,:) trunkCandidates(trunkCandidates~=0)],[outputFolder, 'trunkCandidates.bin'],'t,d,d,d,ui,ui');
% Save other relevant data to reproduce the previous work
bin_save_local([treeFace treeFaceIDX treeFaceTrunkCandidates],[outputFolder, 'treeFace.bin'],'d,d,d,ui,ui');

