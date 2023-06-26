function cost =  parkingCostFcn(X,U,e,data,ref,Qp,Rp,Qt,Rt,distToCenter,safetyDistance)
% Cost function for parking.

% Copyright 2019 The MathWorks, Inc.
    
    p = data.PredictionHorizon;
    
    % process cost
    cost = 0;
    for idx = 1:p
        runningCost = (X(idx+1,:)-ref)*Qp*(X(idx+1,:)-ref)' + U(idx,:)*Rp*U(idx,:)';
        cost = cost + runningCost;
    end
    % terminal cost
    terminal_cost = (X(p+1,:)-ref)*Qt*(X(p+1,:)-ref)' + U(p,:)*Rt*U(p,:)';
    % total cost
    cost = cost + terminal_cost;
end