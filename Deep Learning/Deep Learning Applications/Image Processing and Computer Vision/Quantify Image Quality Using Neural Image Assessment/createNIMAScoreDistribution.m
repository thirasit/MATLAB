function prob = createNIMAScoreDistribution(meanData,stdData)
% Creates a distribution of scores in the range [1, 10].
%
% Copyright 2020 The MathWorks, Inc.

% Rescale the scores from the range [1, 100] to the range [1, 10]
oldMaxScore = 100;
oldMinScore = 1;
newMaxScore = 10;
newMinScore = 1;
meanArr = rescale(meanData,newMinScore,newMaxScore, ...
    'InputMin',oldMinScore,'InputMax',oldMaxScore);
stdArr = stdData*newMaxScore/oldMaxScore;

% Get the maximum entropy distribution
options = optimoptions('fsolve','Display','off', ...
    'MaxFunctionEvaluations',2500,'FunctionTolerance',10e-6, ...
    'MaxIterations',800,'Algorithm','levenberg-marquardt');
nObs = length(meanArr);
prob = zeros(nObs,newMaxScore);
M = newMaxScore;
for i = 1:nObs
    MU = meanArr(i);
    SIGMA = stdArr(i);
    lambda = fsolve(@(x)lagrangianEquation(x,M,MU,SIGMA),zeros(3,1),options);
    probN = exp(-(lambda(1) + lambda(2)*(1:M) + lambda(3)*(((1:M).^2))));
    prob(i,:) = probN;
end

end

function f = lagrangianEquation(l,N,MU,SIGMA)
% Define the equations to be solved to obtain the maximum entropy
% distribution from the Lagrangian function
    P = exp(-(l(1) + l(2)*(1:N)' + l(3)*(((1:N).^2)'))); %P(x)=e^(-lambda1-lambda2*x-lambda3*x^2)
    f(1) = ones(1,N)*P - 1; %sum of probabilities
    f(2) = (1:N)*P - MU; %mean
    f(3) = ((1:N).^2)*P - MU^2-SIGMA^2; %variance
end