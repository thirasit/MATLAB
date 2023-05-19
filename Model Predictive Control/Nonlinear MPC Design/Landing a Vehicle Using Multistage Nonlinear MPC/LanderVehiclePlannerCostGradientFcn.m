function [Gx, Gmv] = LanderVehiclePlannerCostGradientFcn(stage,x,u)
% Lander Vehicle planner cost gradient function.

% Copyright 2023 The MathWorks, Inc.

Gx = zeros(6,1);
Gmv = ones(2,1);
