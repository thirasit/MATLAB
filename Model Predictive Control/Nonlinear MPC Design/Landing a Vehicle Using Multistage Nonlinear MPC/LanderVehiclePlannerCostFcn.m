function J = LanderVehiclePlannerCostFcn(stage,x,u)
% Lander Vehicle planner cost function.

% Copyright 2023 The MathWorks, Inc.

J = sum(u);
