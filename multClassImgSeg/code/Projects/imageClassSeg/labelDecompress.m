% to get rid of none-existing label index so the classifier is not confused

function [fullLabelData] = labelDecompress(cmpLabelData, labelMap)

fullLabelData = zeros(size(cmpLabelData));

for i = 1:length(labelMap)
    fullLabelData(cmpLabelData == i) = labelMap(i);
end




