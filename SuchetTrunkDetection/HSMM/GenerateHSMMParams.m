function [B,C] = GenerateHSMMParams(obs,observationMapping,gaussianSpacing,uniformDuration)
% function [B,C] = GenerateHSMMParams(obs,observationMapping,gaussianSpacing,uniformDuration)
% Generate the variables required by the veterbi algorithm for HSMM
% inference
% Inputs:
% obs - vector of observations
% observationMapping - a matrix mapping the obs to a probability, the first
% row contains the reference obs and the following rows contain probability
% mappings for each state
% gaussianSpacing - the mean and std of the physical spacing between
% primary states, normalised to the slice length
% uniformDuration - normalised length of uniform distribution for state
% duration - In this example this is regarding the duration of the trunk
% state
%
% Outputs:
% B - Observation Probabilty (emiision function)
% C - Duration Probability
%
% Created by
% Suchet Bargoti - 19/05/2014
% Improvement: modular inputs over previous version

% Time Matrix
T = length(obs);

% Max duration
D = ceil(gaussianSpacing(1)+3*gaussianSpacing(2));
% D = 4/0.05; % Changed to a large constant to allow for a larger dummy gap

% Observation probabilty - emmision function
B = zeros(size(observationMapping,1)-1,T);
for i = 1:size(B,1)
    B(i,:) = interpolateValues(observationMapping(1,:),normalisePDF(observationMapping(1,:),observationMapping(i+1,:)),obs);
end

% Duration probabilities
C = zeros(size(B,1),D);
C(1,1:uniformDuration(1)) = 1/uniformDuration(1); % Trunk duration
C(2,:) = gaussmf(1:D,fliplr(gaussianSpacing)); % Gap duration
C(3,1:end) = 1/D; % dummy_gap duration

