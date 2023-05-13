function cineq = TruckTrailerIneqConFcn(stage,x,u,p)
% Inequality constraint function of the path planner of a truck and trailer
% system, used to avoid two static obstacles.

% Copyright 2020-2023 The MathWorks, Inc.

%#codegen
%% Ego and obstacles
% Obstacles are static and do not change shape properties during
% simulation. Then, define it as persistent variables to improve simulation
% efficiency.
persistent obstacles truck trailer
M = p(1);
L1 = p(2);
L2 = p(3);
W1 = p(4);
W2 = p(5);
safetyDistance = 1;
if isempty(obstacles)
    %% Truck and trailer
    truck   = mpcShape('Rectangle', L1, W1);
    trailer = mpcShape('Rectangle', L2, W2);
    %% Obstacles
    obs1 = mpcShape('Rectangle',17.5,20);
    obs2 = mpcShape('Rectangle',17.5,20);
    [obs1.X, obs1.Y] = deal(-11.25,-20);
    [obs2.X, obs2.Y] = deal( 11.25,-20);
    obstacles = {obs1,obs2};
end

%% constraints
% Update trailer positions
trailer.X = x(1) + L2/2*cos(x(3));
trailer.Y = x(2) + L2/2*sin(x(3));
trailer.Theta = x(3);
% Update truck positions
theta1 = x(3) + x(4);
truck.X = x(1) + L2*cos(x(3)) + (M+L1/2)*cos(theta1);
truck.Y = x(2) + L2*sin(x(3)) + (M+L1/2)*sin(theta1);
truck.Theta = theta1;
% Calculate distances from trailer to obstacles
numObstacles = numel(obstacles);
distances1 = zeros(numObstacles,1);
distances2 = zeros(numObstacles,1);
for ct = 1:numObstacles
    [collisionStatus1, distances1(ct)] = ...
        controllib.internal.gjk.Base2d.checkCollision(trailer, obstacles{ct});
    [collisionStatus2, distances2(ct)] = ...
        controllib.internal.gjk.Base2d.checkCollision(truck, obstacles{ct});    

    if collisionStatus1
        distances1(ct) = -10;
    end
    if collisionStatus2
        distances2(ct) = -10;
    end
end
allDistances = [distances1;distances2];
cineq = -allDistances + safetyDistance;