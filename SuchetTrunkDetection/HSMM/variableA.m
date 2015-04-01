function A = variableA(t,nearEndT)
% function A = variableA(t,nearEndT
% creates the transition matrix A depending on where along the row we are. 
% Any points after endStep are converted to a different A matrix
% Designed to only work with the type of state transitions observed at the
% apple farm. 

% Near the start, if at a tree state, we can only transition to a gap
% state
A = [0 1 0;1 0 0; 1 0 0];

% However if near the end, the trunks can only transition to the dummy gap
% state
if t > nearEndT
    A(1,:) = [0 0 1];
end

% Covert to log state
A(A==0) = nan;
A = log(A);