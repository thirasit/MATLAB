function [Gx,Gmv,Gdmv] = costJacobianPlanner(stage,x,u,du,p)
% Jacobian of cost function for parallel parking of a truck-trailer system.

% Copyright 2021 The MathWorks, Inc.

Wmv = eye(2);
Gx = zeros(4,1);
Gmv = 2*Wmv*u;
Gdmv = zeros(2,1);


