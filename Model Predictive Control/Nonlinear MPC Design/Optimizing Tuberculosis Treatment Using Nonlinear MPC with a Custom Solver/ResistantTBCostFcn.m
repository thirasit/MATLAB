function f = ResistantTBCostFcn(X,U,e,data)
% Define the cost for the resistant TB example
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
% Copyright 2018 The MathWorks, Inc.

% Use states from k+1 to k+p
L2 = X(2:end,3);
I2 = X(2:end,5);
% Use MVs from k to k+p-1
U1 = U(1:end-1,1);
U2 = U(1:end-1,2);
% Minimize control efforts plus sum of I2 and L2 population
B1 = 50;
B2 = 500;
f = data.Ts*(0.5*(B1*(U1'*U1) + B2*(U2'*U2)) + sum(sum(L2)) + sum(sum(I2)));

