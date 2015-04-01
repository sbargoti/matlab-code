function obs = DataToSlices(position,value,bins,type)
% function obs = DataToSlices(position,value,bins,type)
% Given data at a particular position and a set value, splits it into the
% bins according to the rule specified by type. 
% type options: 
% 1. 'max'
% 2. 'average'
% 3. 'indices'

% Initialise
if iscell(value)
    obs = cell(length(bins)-1,2);
    obs(:,1) = num2cell((bins(1:end-1) + bins(2:end)) /2);
else
    obs = zeros(length(bins)-1,2);
    obs(:,1) = (bins(1:end-1) + bins(2:end)) /2;
end

% Make sure position is a column vector
posSize = size(position);
if posSize(1) < posSize(2)
    position = position';
end

% Go through each bin and allocate the data
for i = 1:length(bins)-1
    obsInRange_IDX = position(:,1)>bins(i) & position(:,1)<bins(i+1);
    % If there is some data in this region add it to observation
    if sum(obsInRange_IDX)
        switch type
            case 'max'
                obs(i,2) = max(value(obsInRange_IDX)); 
            case 'average'
                obs(i,2) = mean(value(obsInRange_IDX)); 
            case 'indices'
                obs{i,2} = unique([value{obsInRange_IDX}]);
        end
    end
end
    
