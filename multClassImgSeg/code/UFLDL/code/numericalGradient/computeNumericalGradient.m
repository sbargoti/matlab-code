function numgrad = computeNumericalGradient(J, theta)
% numgrad = computeNumericalGradient(J, theta)
% theta: a vector of parameters
% J: a function that outputs a real-number. Calling y = J(theta) will return the
% function value at theta. 
  
% Initialize numgrad with zeros
numgrad = zeros(size(theta));

%% ---------- YOUR CODE HERE --------------------------------------
% Instructions: 
% Implement numerical gradient checking, and return the result in numgrad.  
% (See Section 2.3 of the lecture notes.)
% You should write code so that numgrad(i) is (the numerical approximation to) the 
% partial derivative of J with respect to the i-th input argument, evaluated at theta.  
% I.e., numgrad(i) should be the (approximately) the partial derivative of J with 
% respect to theta(i).
%                
% Hint: You will probably want to compute the elements of numgrad one at a time. 
EPSILON = 10^-4;
tic;
disp('Evaluate numerical gradeint for all theta settings')
for i = 1:length(theta)
    thetaPlus = theta;
    thetaPlus(i) = theta(i) + EPSILON;
    thetaMinus = theta;
    thetaMinus(i) = theta(i) - EPSILON;
    
    numgrad(i) = (J(thetaPlus) - J(thetaMinus))/(2*EPSILON);
%     i
    if toc > 5
    fprintf('thetaNo = %i/%i\n',i, length(theta)); 
    tic;
    end
end

disp('Evaluate numerical gradeint for all theta settings: Done')



%% ---------------------------------------------------------------
end
