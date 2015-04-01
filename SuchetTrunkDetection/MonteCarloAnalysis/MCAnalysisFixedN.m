% This script looks at relatiionship between the accuracy of an inventory
% managment system and the probability of a tree detection algorithm
% Through this we aim to determine how accuractly the tree trunk
% localisation needs to work to achieve a certain degree of accuracy in
% tree trunk detection.
clear all; close all; clc;
% CODE COMPLETE FOR FIXED TREES AND VARIABLE DETECTION ACCURACIES

% Analysis parameters
TotalRep = 1e4; % testing showed that all the data stabilies within a 1000 iterrations.
NumData = 100; % number of trees
accuracy = linspace(0.8,1,50); % trunk detection accuracy
MaxError = 6; % max number offset between trees.
misMatchError = zeros(length(accuracy),MaxError+1);

% Generate a set of quasi random variables
p = haltonset(1,'Skip',1e3,'Leap',1e2);
p = scramble(p,'RR2');
startIDX = randi(1e10,1);

% Iterrate through detection accuracies
for a = 1:length(accuracy)
    curAccuracy = accuracy(a)
    % Go through each tree and see if detection is done properly or not.
    for j = 1:TotalRep
        % Change starting index to re evaluate every time
        startIDX = startIDX + NumData;
        % Selection the detection probability for all the trees in the row
        detectionProb = p(startIDX:startIDX+NumData-1);
        pointDetectionError = +(detectionProb<(1-curAccuracy));
        % Apply signs to detection probability - i.e. a tree can be skipped or
        % double counted by equal probabilities
        errorDirection = +(rand([sum(pointDetectionError==1),1]) > 0.5);
        errorDirection(errorDirection==0) = -1;
        pointDetectionError(pointDetectionError==1) = errorDirection;
        % Obtain sequence error results
        sequenceError = abs(cumsum(pointDetectionError));
        % Evaluate mis match error - number of trees within error margin
        currentError = zeros(1,MaxError+1);
        for i = 0:MaxError
            currentError(i+1) = sum(sequenceError<=i)/NumData;
        end
        % Take cum sum
        misMatchError(a,:) = misMatchError(a,:)+currentError;
    end
    % Take average
    misMatchError(a,:) = misMatchError(a,:)/TotalRep;
end
figure('color','white')
figure('color','white');plot(accuracy,misMatchError);
legend(strread(num2str(0:MaxError),'%s'),'location','northwest');
xlabel('Trunk detection accuracy');
ylabel('Trunk recognition accuracy');
title('Trunk recognition accuracy vs detection accuracy for different recognition sensitivity')
