function xk1 = LaneFollowingEKFStateFcn(xk,u)
% State function used by the Extended Kalman Filter block.
%
% Inputs: 
%           xk: Current state values
%           u:  Current input values
% Outputs:
%           xk1: Updated state values based on xk and uk

% Copyright 2018 The MathWorks, Inc.

uk = [u(1) u(2) u(3) u(4)];
Ts = u(5);
xk1 = getDiscreteMdlForEKF(xk, uk, Ts);

function xk1 = getDiscreteMdlForEKF(xk,uk,Ts)
% This function uses the Euler method to discretize the augmented model
% used by the lane following controller. This discrete model is used by the
% Extended Kalman Filter to estimate the states of our ego car inputs:
%           xk: State values from current time step
%           uk: Current Input
%           Ts: Sample time of the Nonlinear MPC Controller
% Outputs:
%
%           xk1: State values for next time step

%#codegen

M = 10; % Discretize in 'M' steps. Higher the value of 'M', more the accuracy
delta = Ts/M;
xk1 = xk;
for ct=1:M
    xk1 = xk1 + delta*LaneFollowingStateFcn(xk1,uk);
end
