function [Gx,Gu,ge] = ResistantTBCostJacFcn(X,U,e,data)
% Compute analytical gradient of cost for Resistant TB example
%
% States:
%   x(1) = S, number of susceptible individuals
%   x(2) = T, number treated effectively and immune
%   x(3) = L2, latent with resistant TB, non-infections
%   x(4) = I1, infectious with typical TB
%   x(5) = I2, infectious with resistant TB
%
%   L1, latent with typical TB, non-infections, is N - sum(x).
%
% Manipulated variables (MVs):
%   u(1):  "case finding" - Effort expended to identify those needing
%           treatment. Relatively inexpensive.
%   u(2):  "case holding" - Effort to maintain effective treatment.
%           Relatively costly.
%
% Outputs:
%   Gx:  p by nx gradient with respect to the states
%   Gu:  p by nmv gradient with respect to the manipulated variables
%   ge:  scalar gradient with respect to the slack variable.
%
% Copyright 2018 The MathWorks, Inc.

p = data.PredictionHorizon;
nx = data.NumOfStates;
nmv = data.NumOfInputs;
Gx = zeros(p,nx);
Gu = zeros(p,nmv);
B1 = 50;
B2 = 500;
for i = 1:p
    Gx(i,3) = 1;
    Gx(i,5) = 1;
    Gu(i,1) = B1*U(i,1);
    Gu(i,2) = B2*U(i,2);
end
Gx = data.Ts*Gx;
Gu = data.Ts*Gu;
ge = 0;

