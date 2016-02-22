% to get rid of none-existing label index so the classifier is not confused

function [labelData, labelMap, classNameList] = labelCompress(oldLabelData, oldClassNameList)

exsitinglabels = unique(oldLabelData);

[dim1 dim2 dim3] = size(oldLabelData);

% label analysis remove class that is too small
nLabel = max(exsitinglabels);
classPercentage = zeros(1,nLabel);
for iLabel = 1:nLabel
    currentLabelIdx = (oldLabelData == iLabel);
    classPercentage(iLabel) = sum(sum(sum(currentLabelIdx)))/(dim1*dim2*dim3);    
end

labels = 1:max(exsitinglabels);
labelMap = labels(find(classPercentage > 1e-4));

labelData = zeros(size(oldLabelData));
nLabel = length(labelMap);
for iLabel = 1:nLabel
    currentLabelIdx = (oldLabelData == labelMap(iLabel));
    labelData(currentLabelIdx) = iLabel;  
    classNameList{iLabel} =  oldClassNameList{labelMap(iLabel)};
end

% set others to void
currentLabelIdx = (labelData == 0); 
labelData(currentLabelIdx) = 1;  

