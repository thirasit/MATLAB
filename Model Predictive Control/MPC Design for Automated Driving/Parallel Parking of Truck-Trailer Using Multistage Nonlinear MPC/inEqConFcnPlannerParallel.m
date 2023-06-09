function cineq = inEqConFcnPlannerParallel(stage,x,u,du,p)
% Inequality constraints for parallel parking of a truck-trailer system.

% Copyright 2021-2023 The MathWorks, Inc.

persistent obstacles truck trailer

%% Get parameters
M1 = p(1);
L1 = p(2);
L2 = p(3);
W1 = p(4);
W2 = p(5);
wallLength = p(6);  
wallWidth = p(7);
xPos = x(1);
yPos = x(2);
theta2 = x(3);
beta = x(4);
safetyDistance = 1;

%% Create obstacles
% Obstacles are static and do not change shape properties during
% simulation. Then, define it as persistent variables to improve simulation
% efficiency.
if isempty(obstacles)
    %% Truck and trailer
    truck = mpcShape('Rectangle', L1+M1, W1);
    trailer = mpcShape('Rectangle', L2, W2);

    %% Obstacles
    obs1 = mpcShape('Rectangle',    wallWidth,   wallLength);
    obs2 = mpcShape('Rectangle',    wallWidth,   wallLength);
    obs3 = mpcShape('Rectangle',    wallWidth, 3*wallLength);
    obs4 = mpcShape('Rectangle', .5*wallWidth,           30);

    [obs1.X, obs1.Y] = deal(  -5, -25);
    [obs2.X, obs2.Y] = deal(  -5,  25);
    [obs3.X, obs3.Y] = deal( -25,   0);
    [obs4.X, obs4.Y] = deal(-2.5,   0);
    
    obstacles = {obs1;obs2;obs3;obs4};
end

%% Constraints
% Update trailer positions
trailer.X = xPos + L2/2*cos(theta2);
trailer.Y = yPos + L2/2*sin(theta2);
trailer.Theta = theta2;

% Update truck positions
theta1  = theta2 + beta;
truck.X = xPos + L2*cos(theta2) + ((M1+L1)/2)*cos(theta1);
truck.Y = yPos + L2*sin(theta2) + ((M1+L1)/2)*sin(theta1);
truck.Theta = theta1;

% Calculate distances from truck and trailer to obstacles
numObstacles = size(obstacles,1);
distances1 = zeros(numObstacles,1);
distances2 = zeros(numObstacles,1);
for ct = 1:numObstacles
    [~, distances1(ct)] = ...
        controllib.internal.gjk.Base2d.checkCollision(trailer, obstacles{ct});
    [~, distances2(ct)] = ...
        controllib.internal.gjk.Base2d.checkCollision(truck, obstacles{ct});
end
allDistances = [distances1;distances2];
cineq = -allDistances + safetyDistance;
end