function cost =  costFcnPlanner(stage,x,u,du,p)
% Cost function for parallel parking of the truck-trailer system.

% Copyright 2021 The MathWorks, Inc.
    
Wmv = eye(2);
cost =  u'*Wmv*u;


