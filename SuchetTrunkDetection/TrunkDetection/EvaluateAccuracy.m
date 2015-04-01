function EvaluateAccuracy(gtPoints,trunkXEst,treeFace)

% Evaluate accuracy
% for each gtPoint, find the nearest true point
% trunkXEst = cell2mat(trunkIdxBottom(:,1));
[idx,d] = knnsearch(gtPoints(:,1),trunkXEst);
min_d = 0.2;
true_positives = find(d<min_d);
false_positives = find(d>=min_d);
% Draw results
figure('color','white')
skipper = 1;
h_tf = plot(treeFace(1:skipper:end,1),treeFace(1:skipper:end,3),'.'); hold all;
h_gt = plot(gtPoints(:,1),gtPoints(:,2),'ro','markerfacecolor','r','markersize',8);
axis equal; axis fill;
x_results = min(treeFace(:,1)):0.01:max(treeFace(:,1));
tp_results = zeros(size(x_results));
fp_results = zeros(size(x_results));
trunk_w = 0.05;
for i = 1:length(trunkXEst)
    if sum(true_positives==i)
        tp_results(x_results > (trunkXEst(i) - trunk_w) & x_results < (trunkXEst(i) + trunk_w)) = 3;
    elseif sum(false_positives==i)
        fp_results(x_results > (trunkXEst(i) - trunk_w) & x_results < (trunkXEst(i) + trunk_w)) = 3;
    end
end
        
h_fp = plot(x_results,fp_results,'k','linewidth',3);
t_tp = plot(x_results,tp_results,'g','linewidth',3);
legend([h_gt t_tp h_fp],{'True trunk locations','TP trunk state','FP trunk state'},'FontSize',16)
fprintf('Total trunks, Detected trunks, TP, FP\n')
fprintf('%d\t%d\t%d\t%d\t\n',size(gtPoints,1),length(trunkXEst),length(true_positives),length(false_positives))
% fprintf('Total number of trunks: %d\n',size(gtPoints,1));
% fprintf('Detected number of trunks: %d\n',length(trunkXEst));
% fprintf('True Positives: %d\n',length(true_positives));
% fprintf('False Positives: %d\n',length(false_positives));