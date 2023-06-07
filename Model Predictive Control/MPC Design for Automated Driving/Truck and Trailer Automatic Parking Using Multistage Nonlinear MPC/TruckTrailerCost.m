function cost =  TruckTrailerCost(stage,x,u,p)
% Cost function of the path planner of a truck and trailer system

% Copyright 2020-2023 The MathWorks, Inc.

%#codegen
Wmv = eye(2);
cost = u'*Wmv*u;

