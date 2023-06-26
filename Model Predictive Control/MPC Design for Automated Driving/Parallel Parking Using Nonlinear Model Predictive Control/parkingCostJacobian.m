function [G,Gmv,Ge] = parkingCostJacobian(X,U,e,data,ref,Qp,Rp,Qt,Rt,distToCenter,safetyDistance)
% Jacobian of cost function for parking.

% Copyright 2019 The MathWorks, Inc.

    p = data.PredictionHorizon;
    G = zeros(p,data.NumOfStates);
    Gmv = zeros(p,length(data.MVIndex));
    Ge = 0;
    for i=1:p
        % Running cost Jacobian
        G(i,:) = 2 * (X(i+1,:)-ref) * Qp;
        Gmv(i,:) = 2 * U(i,:) * Rp;
    end
    G(p,:) = G(p,:) + 2 * (X(p+1,:)-ref) * Qt; 
    Gmv(p,:) = Gmv(p,:) + 2 * U(p,:) * Rt;
    
end

