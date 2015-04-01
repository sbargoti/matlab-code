function clusterIDs = ExtractClusters(xData,idxPerData,clusterIDs,max_c,min_ppc,loadClusters)
% function clusterClass = ExtractClusters(xData,idxPerData,clusterIDs,max_c,min_ppc,loadClusters)
% Get a vector of cluster classes out, each class represented by a class ID
%
% Input:
% xData: data over which we need to cluster over
% indexPerData: index points per data point (in cell format)
% clusterIDs: the indexPerData map onto this vector, the input is vector of
% zeros to initialise the output
% max_c: max number of clusters (should aim to overshoot by a factor of
% 3-4)
% min_ppc: min points per cluster - used to get rid of thin sparse clusters
% loadClusters: the path to the .mat file containing the raw clusters as
% previously saved
%
% Output:
% clusterIDs - vector of clusterIDs

% Evaluate clusters - this process is random each time, so cannot be
% replicated unless we save the data
clusters = kmeans(xData,max_c,'emptyaction','drop');
if loadClusters
    if exist(loadClusters,'file')
        load(loadClusters);
    else
        save(loadClusters,'clusters');
    end
end

% Assign clusters to indices
for i = 1:length(idxPerData)
    clusterIDs(idxPerData{i}) = clusters(i);
end

% Unique clusters present
uniqueIDs = unique(clusterIDs);

% Get rid of small clusters
for i = 1:length(uniqueIDs)
    pointsPerCluster = sum(clusterIDs==uniqueIDs(i));
    if pointsPerCluster < min_ppc
        clusterIDs(clusterIDs==uniqueIDs(i))=0;
    end
end

