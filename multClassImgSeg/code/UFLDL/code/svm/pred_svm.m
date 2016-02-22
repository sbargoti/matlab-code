% from kmeansDemo
function labels = pred_svm(trainXCs, theta)

[val,labels] = max(trainXCs*theta, [], 2);