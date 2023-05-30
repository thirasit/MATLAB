function f = oxidationCostFcn(X,U,e,data)
% We want to maximize the C2H4O production rate at the end of the
% prediction horizon. But since the nonlinear MPC controller minimizes cost
% function, we have to change the sign to accomodate this.

% Copyright 2017-2022 The MathWorks, Inc.

% Since u1 is a decision variable (MV), we have to use U(end-1,1) instead
% of U(end,1) to calculate the cost.  Similarly, Since u3 is not a decision
% variable (MD), we can use U(end,3) to calculate the cost.  The assumption
% is that U(end,3) would be able to remain as U(end-1,3) after optimal
% condition is achieved.
f = -(U(end,3)./U(end-1,1).*X(end,3).*X(end,4)) + 1*e;
