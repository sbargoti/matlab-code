function path = Viterbi(PAI, A, B, C)
% Calculate the optimal state sequence given the input parameters
% All input parameters are to be given in the log-domain
% N is the number of states
% T is the number of measurements
% D is the maximum duration in a state
% PAI represents the log of initial probability - Nx1
% A represents the log of the transition matrix - NxN
% B represents the log of the measurement probabilities - NxT
% C represents the log of the duration probabilities - NxD

% Save the function handle
if isa(A,'function_handle')
    AFCN = A; % doesn't matter if it isnt a function handle
    A = AFCN(1);
end

%Creation of variables
N = size(A,1); 
T = size(B,2);
D = size(C,2);

% Handle short input sequence where the input sequence is shorter than the
% maximum state duration.
if(D > T)
    D = T;
end

delta = -10000 * ones(T,N,D);
phi = zeros(T,N,D,3);
path = zeros(0,3);

%Initialisation
for d = 1:D
    for j = 1:N
        measurementSum = sum(B(j, 1:d));
        delta(d,j,d) = PAI(j) + C(j,d) + measurementSum; 
    end
end 

%Recursion
for t = 2:T 
    if exist('AFCN','var')
        A = AFCN(t);
    end
    for j = 1:N
       for d = 1:D
             
           if(t-d < 1)
               continue;
           end
           measurementSum = sum(B(j, t-d+1:t));
           
           delta_ = squeeze(delta(t-d,:,:)); 
           A_ = repmat(A(:,j), 1, D);
           
           fMat = delta_ + A_ + C(j,d) + measurementSum;
           [deltaMax, index] = max(fMat(:));
           [i_prim_star, d_prim_star] = ind2sub(size(fMat), index);
           
           delta(t,j,d) = deltaMax; 
           phi(t,j,d,:) = [t-d,i_prim_star,d_prim_star];  
       end
    end
end

%Termination
delta_ = squeeze(delta(T,:,:));
[deltaMax, index] = max(delta_(:));
[i_T, d_T] = ind2sub(size(delta_), index);

addedState = [T i_T d_T];
path = [path; addedState];

t_p = addedState(1);
i_p = addedState(2);
d_p = addedState(3);

%Back-tracking
while(t_p > 1)
    addedState = squeeze(phi(t_p, i_p, d_p,:))';
    
    if(addedState(1) < 1)
        break;
    end
    
    path = [path; addedState];
    
    t_p = addedState(1);
    i_p = addedState(2);
    d_p = addedState(3);
end


end