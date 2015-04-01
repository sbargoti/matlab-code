% function SaveTrunkTimes(dataPath,modelPath)
% Save the time stamps at each trunk location 
% Current purpose is to extract the images at those times
disp(dataPath)
d = bin_load([dataPath, 'treeFace.bin'],'d,d,d,ui,ui');
treeFace = d(:,1:3); treeFaceIDX = d(:,end-1); treeFaceTrunkCandidates = d(:,end);
load([dataPath,'segmentedTrunks.mat']);
obsX = obsTotal(:,1);

d2 = bin_load([dataPath, 'trunkCandidates.bin'],'t,d,d,d,ui,ui');
times = zeros(size(d,1),1);
times(d(:,end)~=0,1) = d2(:,1);
trunkTime = zeros(size(trunkIdxBottom,1),1);
for i = 1:size(trunkIdxBottom,1)
    if ~isempty(trunkIdxBottom{i,2})
        trunkCandidateTimes = times(trunkIdxBottom{i,2});
        trunkTime(i) = mean(trunkCandidateTimes(trunkCandidateTimes~=0));
    end
end

% Fill out zero times using interpolation
xout = cell2mat(trunkIdxBottom(:,1));
xin = xout(trunkTime~=0);
yin = trunkTime(trunkTime~=0);
trunkTime = interp1(xin,yin,xout);

% Write trunk Time to .bin file
% bin_save_local(sort(trunkTime),[dataPath,'trunkTimes.bin'],'t');
        