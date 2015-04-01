% This script looks at relatiionship between the accuracy of an inventory
% managment system and the probability of a tree detection algorithm
% Through this we aim to determine how accuractly the tree trunk
% localisation needs to work to achieve a certain degree of accuracy in
% tree trunk detection.
clear all; close all; clc;

% Reseed random number generator
rng('shuffle');

% Analysis parameters
TotalRep = 1e5; % testing showed that all the data stabilies within a 1000 iterrations.
NumData = 50;%:5:100; % number of trees
accuracy = [0.9,0.92,0.94,0.96,0.98,0.99]; % detection accuracy
% accuracy = 0.8:0.005:1; % trunk detection accuracy
MaxError = 6; % max number offset between trees.
misMatchError = zeros(length(NumData),MaxError+1,length(accuracy));
errorTypeDistribution = [0.1 0.2 1]; %20% chance of +1, 20% chance of -1, 60% chance of local error

% Iterrate through detection accuracies
for n = 1:length(NumData)
    curNum = NumData(n)
    for a = 1:length(accuracy)
        curAccuracy = accuracy(a)
        % Go through each tree and see if detection is done properly or not.
        for j = 1:TotalRep
            % Selection the detection probability for all the trees in the
            % row - randomly generated numbers between 1,0
            detectionProb = rand(curNum,1);
            pointDetectionError = +(detectionProb<(1-curAccuracy));
            % Apply signs to detection probability - i.e. a tree can be skipped or
            % double counted by equal probabilities, and error type of zero
            % corresponds to a locally erronous detection
            errorType = rand([sum(pointDetectionError==1),1]);
            errorType(errorType<errorTypeDistribution(1))=-1;
            errorType(errorType>errorTypeDistribution(2))=0;
            errorType = ceil(errorType);
            errorLocations = find(pointDetectionError);
            % Feed the error tyes back to the sequence
            pointDetectionError(pointDetectionError==1) = errorType;
            % Obtain sequence error results
            sequenceError = abs(cumsum(pointDetectionError));
            sequenceError(errorLocations(errorType==0)) = sequenceError(errorLocations(errorType==0)) + 1;
            % Evaluate mis match error - number of trees within error margin
            currentError = zeros(1,MaxError+1);
            for i = 0:MaxError
                currentError(i+1) = sum(sequenceError<=i)/curNum;
            end
            % Take cum sum
            misMatchError(n,:,a) = misMatchError(n,:,a)+currentError;
        end
        % Take average
        misMatchError(n,:,a) = misMatchError(n,:,a)/TotalRep;
    end
end
figure('color','white')
graphMat = squeeze(misMatchError(:,2,:));
plot(NumData,graphMat);
legend(strread(num2str(accuracy),'%s'),'location','southwest');
xlabel('Total number of trees in the row');
ylabel('Cumulative Recognition rate')
title('Recognition rate within \pm 1 tree')
ylim([0.55 1.05])

figure('color','white')
graphMat = squeeze(misMatchError(:,3,:));
plot(NumData,graphMat);
legend(strread(num2str(accuracy),'%s'),'location','southwest');
xlabel('Total number of trees in the row');
ylabel('Cumulative Recognition rate')
title('Recognition rate within \pm 2 tree')
ylim([0.55 1.05])

% legend(strread(num2str(0:MaxError),'%s'),'location','northwest');
% xlabel('Trunk detection accuracy');
% ylabel('Trunk recognition accuracy');
% title('Trunk recognition accuracy vs detection accuracy for different recognition sensitivity')
