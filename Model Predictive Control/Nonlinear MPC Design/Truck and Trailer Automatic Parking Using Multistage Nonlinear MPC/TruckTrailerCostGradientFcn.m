function [Gx,Gmv] = TruckTrailerCostGradientFcn(stage,x,u,p)
% Analytical gradient of the cost function of the path planner of a truck
% and trailer system.

% Copyright 2020-2023 The MathWorks, Inc.

%#codegen
Wmv = eye(2);
Gx = zeros(4,1);
Gmv = 2*Wmv*u;
