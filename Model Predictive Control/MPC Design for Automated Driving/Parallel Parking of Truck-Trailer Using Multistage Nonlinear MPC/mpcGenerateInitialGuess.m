function [z0,xGuess,yGuess] = mpcGenerateInitialGuess(initialPose,targetPose,xMiddle,yMiddle,pPlanning)
% Create an initial guess for the multistage NLMPC path planner for the
% parking of truck-trailor system example.

% Copyright 2021 The MathWorks, Inc.

%% Initial guess
u0 = zeros(2,1);

% Parallel parking
p1 = round(pPlanning/2);
p2 = pPlanning - p1 + 1;
thetaMiddle = pi/2;
xGuess = [linspace(initialPose(1),xMiddle,p1),linspace(xMiddle,targetPose(1),p2)];
yGuess = [linspace(initialPose(2),yMiddle,p1),linspace(yMiddle,targetPose(2),p2)];
thetaGuess = [linspace(initialPose(3),thetaMiddle,p1),linspace(thetaMiddle,targetPose(3),p2)];

betaGuess = zeros(1,pPlanning+1);
stateGuess = [xGuess;yGuess;thetaGuess;betaGuess];

z0 = zeros(20*8 + 4,1);
for ct=1:pPlanning
    z0((ct-1)*8+1:ct*8,1) = [stateGuess(:,ct);u0;u0];
end
z0(8*pPlanning+1:end,1) = stateGuess(:,pPlanning+1);
