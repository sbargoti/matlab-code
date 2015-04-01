function stateIdxMerged= MergeWideStates(stateIdx)
% Merge double trees into one

% Initialise
stateIdxMerged = stateIdx(1,:);

% Merge two trunk points if they really close together
for i = 2:size(stateIdx,1)
    if abs(stateIdxMerged{end,1} - stateIdx{i,1}) < 0.25 % If they are really close to each other
        stateIdxMerged{end,1} = (stateIdxMerged{end,1} + stateIdx{i,1})/2;  % Take average centroid
        stateIdxMerged{end,2} = union(stateIdxMerged{end,2},stateIdx{i,2});
    else
        stateIdxMerged(end+1,:) = stateIdx(i,:);
    end
end

end