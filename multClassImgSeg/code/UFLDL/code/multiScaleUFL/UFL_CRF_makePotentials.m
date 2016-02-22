function [nodePot,edgePot, edgeStruct] = UFL_CRF_makePotentials(imData, hypothesis)

% [nRows, nCols, nColour] = size(imData);
[numClasses imDim1 imDim2] = size(hypothesis);

%% 1 make node potential using the hypothesis from softmax regression
fprintf('Constructing Node Potential\n')

% nodePot = zeros(nNodes,maxState);
nodePotTemp = reshape(hypothesis,[numClasses imDim1*imDim2]);
nodePotTemp = nodePotTemp';
% nodePot = exp(nodePotTemp);
nodePot = nodePotTemp;


%% 2 make edge potential using the image data
fprintf('Constructing Edge Potential\n')

% edgePot = zeros(maxState,maxState,nEdges);
% [Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct] = makeCRFGraph(imFeatResp, currentImage{1}, currentSegLabel{1}, nClass);

nNodes = imDim1*imDim2;
nStates = numClasses; % 20 classes plus background, what to do with state 255?

% 2.1 adjacency matrix
adj = sparse(nNodes,nNodes);

% Add Down Edges
ind = 1:nNodes;
exclude = sub2ind([imDim1 imDim2],repmat(imDim1,[1 imDim2]),1:imDim2); % No Down edge for last row
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+1)) = 1;

% Add Right Edges
ind = 1:nNodes;
exclude = sub2ind([imDim1 imDim2],1:imDim1,repmat(imDim2,[1 imDim1])); % No right edge for last column
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+imDim1)) = 1;

% Add Up/Left Edges
adj = adj+adj';
edgeStruct = UGM_makeEdgeStruct(adj,nStates);



% 2.2 Make edge features (based on colour only instead of feature)
sharedFeatures = [1 0 0 0];
% sharedFeatures = zeros(1,nNodeFeatures);
sharedFeatures(1) = 1; % share bias

imData = reshape(imData, [imDim1*imDim2, 3]);
imData = imData';
imData = reshape(imData, [1 3 imDim1*imDim2]);
imDataNode = [ones(1,1,nNodes) imData]; % add bias

Xedge = UGM_makeEdgeFeaturesInvAbsDif(imDataNode,edgeStruct.edgeEnds,sharedFeatures);
nEdgeFeatures = size(Xedge,2);
edgeMap = zeros(nStates,nStates,edgeStruct.nEdges,nEdgeFeatures,'int32');
%edgeMap = zeros(nStates,nStates,edgeStruct.nEdges,nEdgeFeatures);


% edgeMapTmp = zeros(nStates,nStates,nEdgeFeatures,'int32');
% for f = 1:nEdgeFeatures
% 	for s = 1:nStates
% 		edgeMapTmp(s,s,f) = p;
% 	end
% 	p = p+1;
% end
% 
% edgeMap = permute(repmat(edgeMapTmp,[1 1 1 edgeStruct.nEdges]),[1 2 4 3]);

p = 1; % start number of parameter as 1, the node map is not counted because it has already been trained
% not enough memory
for f = 1:nEdgeFeatures
	for s = 1:nStates
		edgeMap(s,s,:,f) = p;
	end
	p = p+1;
end



nEdgeFeatures = size(Xedge,2);
nEdges = edgeStruct.nEdges;
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;
edgePot = zeros(numClasses,numClasses,nEdges);

% need to train w somehow
i=1;
for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);
    for s1 = 1:nStates(n1)
        for s2 = 1:nStates(n2)
            for f = 1:nEdgeFeatures
                if edgeMap(s1,s2,e,f) > 0
%                     edgePot(s1,s2,e) = edgePot(s1,s2,e) + w(edgeMap(s1,s2,e,f))*Xedge(i,f,e);
                    edgePot(s1,s2,e) = edgePot(s1,s2,e) + Xedge(i,f,e);
                end
            end
            edgePot(s1,s2,e) = exp(edgePot(s1,s2,e));
        end
    end
end

% edgePot = 0.01*edgePot;