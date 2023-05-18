function J = FlyingRobotCostFcn(stage, x, u)
% Stage cost function of the flying robot.
%
% The stage cost is the sum of fuel consumption (all thrusts are positive)

% Copyright 2018-2021 The MathWorks, Inc.
J = u(1) + u(2) + u(3) + u(4);
