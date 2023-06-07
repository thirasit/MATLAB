function [z0, XY0] = TruckTrailerInitialGuess(initialPose,targetPose,u0,p)
% Generate initial guess for decision variables used by the path planner of
% a truck and trailer system.

% Copyright 2020-2023 The MathWorks, Inc.

% if y0 > -5 (truck above the obstacle), one way-point is used
if initialPose(2) >= -5
    p1 = round(p/2);
    p2 = p - p1 + 1;
    xMiddle = 0; 
    yMiddle = 10;
    thetaMiddle = pi/4;
    xGuess = [linspace(initialPose(1),xMiddle,p1),linspace(xMiddle,targetPose(1),p2)];
    yGuess = [linspace(initialPose(2),yMiddle,p1),linspace(yMiddle,targetPose(2),p2)];
    thetaGuess = [linspace(initialPose(3),thetaMiddle,p1),linspace(thetaMiddle,targetPose(3),p2)];
% if y0 < -10 (truck below the obstacle), two way-points are used
else
    p1 = round(p/3);
    p2 = round(p/3);
    p3 = p - p1 -p2 + 1;
    x1 = initialPose(1)+sign(initialPose(1))*10; 
    y1 = 10;
    theta1 = pi/6;
    x2 = 0; 
    y2 = 10;
    theta2 = pi/3;
    xGuess = [linspace(initialPose(1),x1,p1),linspace(x1,x2,p2),linspace(x2,targetPose(1),p3)];
    yGuess = [linspace(initialPose(2),y1,p1),linspace(y1,y2,p2),linspace(y2,targetPose(2),p3)];
    thetaGuess = [linspace(initialPose(3),theta1,p1),linspace(theta1,theta2,p2),linspace(theta2,targetPose(3),p3)];
end
betaGuess = zeros(1,p+1);
stateGuess = [xGuess;yGuess;thetaGuess;betaGuess];
z0 = [];
for ct=1:p
    z0 = [z0;stateGuess(:,ct);u0];
end
z0 = [z0;stateGuess(:,ct)];
XY0 = stateGuess(1:2,:)';

