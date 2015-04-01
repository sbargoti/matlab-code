function stateIdx = findIdxAtStates(idxPerSlice,states)
% Given the HSMM estimates states find the point IDX where states==1

% For slices where state is a trunk, find th e indices
correctStatesIdx = find(states==1);
stateIdx = idxPerSlice(correctStatesIdx,:);
% Look at the number of points per trunk
numPointsPerState = cellfun(@(x) length(x),stateIdx(:,2));
minPointsRequired = 5;

% remove any empty cells

% if there are not enough points, include the neighbourhood slices
for i = 1:size(stateIdx,1)
    if numPointsPerState(i) < minPointsRequired
        stateIdx{i,2} = union(idxPerSlice{max(1,correctStatesIdx(i)-1),2},stateIdx{i,2});
        stateIdx{i,2} = union(idxPerSlice{min(length(idxPerSlice),correctStatesIdx(i)+1),2},stateIdx{i,2});
        if length(stateIdx{i,2}) < minPointsRequired
            stateIdx{i,2} = union(idxPerSlice{max(1,correctStatesIdx(i)-2),2},stateIdx{i,2});
            stateIdx{i,2} = union(idxPerSlice{min(length(idxPerSlice),correctStatesIdx(i)+2),2},stateIdx{i,2});
        end
    end
end
end