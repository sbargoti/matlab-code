% This script looks at relatiionship between the accuracy of an inventory
% managment system and the probability of a tree detection algorithm
% Through this we aim to determine how accuractly the tree trunk
% localisation needs to work to achieve a certain degree of accuracy in
% tree trunk detection.
clear all; close all; clc;

% Analysis parameters
TotalRep = 1e4; % testing showed that all the data stabilies within a 1000 iterrations.
NumData = 10:20:110; % number of trees
accuracy = [0.9,0.92,0.94,0.96,0.98,0.99];
% accuracy = 0.8:0.005:1; % trunk detection accuracy
MaxError = 6; % max number offset between trees.
misMatchError = zeros(length(NumData),MaxError+1,length(accuracy));

% Generate a set of quasi random variables
p = haltonset(1,'Skip',1e3,'Leap',1e2);
p = scramble(p,'RR2');
startIDX = randi(1e10,1);

% Iterrate through detection accuracies
for n = 1:length(NumData)
    curNum = NumData(n)
    for a = 1:length(accuracy)
        curAccuracy = accuracy(a);
        % Go through each tree and see if detection is done properly or not.
        for j = 1:TotalRep
            % Change starting index to re evaluate every time
            startIDX = startIDX + curNum;
            % Selection the detection probability for all the trees in the row
            detectionProb = p(startIDX:startIDX+curNum-1);
            pointDetectionError = +(detectionProb<(1-curAccuracy));
            % Apply signs to detection probability - i.e. a tree can be skipped or
            % double counted by equal probabilities
            errorDirection = +(rand([sum(pointDetectionError==1),1]) > 0.5);
            errorDirection(errorDirection==0) = -1;
            pointDetectionError(pointDetectionError==1) = errorDirection;
            % Obtain sequence error results
            sequenceError = abs(cumsum(pointDetectionError));
            % Evaluate mis match error - number of trees within error margin
            currentError = min(sequenceError(end),MaxError);
            misMatchError(n,currentError+1,a) = misMatchError(n,currentError+1,a)+1;
        end
        % Normalise error
        misMatchError(n,:,a) = misMatchError(n,:,a)./TotalRep;
        % Cumulate as recognition <= num tree error
        misMatchError(n,:,a) = cumsum(misMatchError(n,:,a));
    end
end


return
figure('color','white')
graphMat = squeeze(misMatchError(:,2,:));
plot(NumData,graphMat);
legend(strread(num2str(accuracy),'%s'),'location','southwest');
xlabel('Number of trees down the row');
ylabel('Recognition rate')
title('Recognition rate within \pm 3 tree')
ylim([0.25 1.05])

figure('color','white')
graphMat = squeeze(misMatchError(:,3,:));
plot(NumData,graphMat);
legend(strread(num2str(accuracy),'%s'),'location','southwest');
xlabel('Number of trees down the row');
ylabel('Recognition rate')
title('Recognition rate within \pm 2 tree')
ylim([0.55 1.05])

% legend(strread(num2str(0:MaxError),'%s'),'location','northwest');
% xlabel('Trunk detection accuracy');
% ylabel('Trunk recognition accuracy');
% title('Trunk recognition accuracy vs detection accuracy for different recognition sensitivity')
