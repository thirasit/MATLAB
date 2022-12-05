function Jac = pdmMotorModelStateJacobianFcn(x,varargin)
%PDMMOTORMODELSTATEJACOBIANFCN
%
% Jacobian of motor model state equations. See pdmMotorModelStateFcn for
% the model equations.
%
%  Jac = pdmMotorModelJacobianFcn(x,u,J,Ts)
%
%  Inputs:
%    x  - state with elements [angular velocity; friction] 
%    u  - motor torque input
%    J  - motor inertia
%    Ts - sampling time
%
%  Outputs:
%    Jac - state Jacobian computed at x
%

%  Copyright 2016-2017 The MathWorks, Inc.

% Model properties
J  = varargin{2};
Ts = varargin{3};

% Jacobian
Jac = [...
    1-Ts/J*x(2) -Ts/J*x(1); ...
    0 1];
end