% the point of this function is to ignore the void class that is not in the
% evaluation.

function myClassifierPerf(CPDataset, validClassIdx, classNameList)

confMatrix = CPDataset.CountingMatrix(validClassIdx,validClassIdx);



P = zeros(1,length(validClassIdx));
R = zeros(1,length(validClassIdx));
F = zeros(1,length(validClassIdx));

for i = 1:length(validClassIdx)
    P(i) = confMatrix(i,i)/sum(confMatrix(:,i)); % ze right way
    R(i) = confMatrix(i,i)/sum(confMatrix(i,:)); % ze right way\
    F(i) = 2*P(i)*R(i)/(P(i)+R(i));

%     normConfMatrix(i,:) = confMatrix(i,:)/sum(confMatrix(i,:));    
end
fprintf('F measure %1.4f\n', mean(F));

% mean(F)

normConfMatrix = zeros(size(confMatrix));
for i = 1:length(validClassIdx)
    normConfMatrix(:,i) = confMatrix(:,i)/sum(confMatrix(:,i)); % ze right way
%     normConfMatrix(i,:) = confMatrix(i,:)/sum(confMatrix(i,:));    
end

normConfMatrix

perClassAcc = diag(normConfMatrix);

for i=1:length(diag(normConfMatrix))
    fprintf('%s \t %1.4f\n', classNameList{validClassIdx(i)}, perClassAcc(i));
end


globalAcc = sum(diag(confMatrix))/sum(sum(confMatrix))
avgClassAcc = mean(perClassAcc)


figure;imagesc(normConfMatrix);

for i=1:length(diag(normConfMatrix))
labelNameList{i} = classNameList{validClassIdx(i)};
end

matrix2latex(normConfMatrix*100, 'poopoo.txt', ...
    'rowLabels', labelNameList, 'columnLabels', labelNameList, ...
    'alignment', 'r', 'format', '%2.1f','size','small');