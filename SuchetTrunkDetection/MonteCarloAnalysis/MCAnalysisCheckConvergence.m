% This script looks at relatiionship between the accuracy of an inventory
% managment system and the probability of a tree detection algorithm
% Through this we aim to determine how accuractly the tree trunk
% localisation needs to work to achieve a certain degree of accuracy in
% tree trunk detection.
clear all; close all; clc;
%%% THIS INTERMEDIATE SCRIPT CHECKS THE CONVERGENCE - IE WHAT VALUE OF TOTALREP IS REQUIRED.  

% Analysis parameters
TotalRep =  1e4;
NumData = 100; % number of trees
accuracy = 0.95; % trunk detection accuracy
MaxError = 6; % max number offset between trees. 
misMatchError = zeros(TotalRep, MaxError+1);

% Generate a set of quasi random variables
p = haltonset(1,'Skip',1e3,'Leap',1e2);
p = scramble(p,'RR2');
startIDX = randi(1e10,1);

% Go through each tree and see if detection is done properly or not.
for j = 1:TotalRep
    % Change starting index to re evaluate every time
    startIDX = startIDX + NumData;
    % Selection the detection probability for all the trees in the row
    detectionProb = p(startIDX:startIDX+NumData-1);
    pointDetectionError = +(detectionProb<(1-accuracy));
    % Apply signs to detection probability - i.e. a tree can be skipped or
    % double counted by equal probabilities
    errorDirection = +(rand([sum(pointDetectionError==1),1]) > 0.5);
    errorDirection(errorDirection==0) = -1;
    pointDetectionError(pointDetectionError==1) = errorDirection;
    % Obtain sequence error results
    sequenceError = abs(cumsum(pointDetectionError));
    
    % Evaluate mis match error - number of trees within error margin
    for i = 0:MaxError
        misMatchError(j,i+1) = sum(sequenceError<=i)/NumData;
    end
end

% Plot the mis match error error as a fucntion of the iterations
iterVect = [1:TotalRep]';
meanError = cumsum(misMatchError,1)./repmat(iterVect,1,MaxError+1);
figure('color','white')
plot(iterVect,meanError);
title('Convergence of errors per mc iterration')
xlabel('Number of iterations')
ylabel('Error rate for different offset thresholds')