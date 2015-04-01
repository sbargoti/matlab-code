function states = HSMMInference(PAI,A,B,C,obs)
% function states = HSMMInference(PAI,A,B,C)
% outputs the most likely state at each observation

% Viterbi Algorithm
pathChanges = ViterbiHead(PAI, A, B, C);

% Extract states and duration
hsmmPath = zeros(1, size(obs,1));
for i = 1:size(pathChanges,1)
    startPos = pathChanges(i,1);
    value = pathChanges(i,2); % State value
    duration = pathChanges(i,3); % time duration
    
    % assign states per discrete time
    for d = 0:duration-1
        hsmmPath(1,startPos-d) = value;
    end
end

% Rescale states to demonstrate graphically
scaledStates = zeros(size(hsmmPath));
scaledStates(hsmmPath == 1) = 1; % Tree
scaledStates(hsmmPath == 2) = 0; % Boundary

% Output
states = scaledStates;