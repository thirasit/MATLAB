function J = pdmMotorModelMeasJacobianFcn(x,varargin)
%PDMMOTORMODELMEASJACOBIANFCN
%
% Jacobian of motor model measurement equations. See
% pdmMotorModelMeasurementFcn for the model equations.
%
%  Jac = pdmMotorModelMeasJacobianFcn(x,u,J,Ts)
%
%  Inputs:
%    x  - state with elements [angular velocity; friction] 
%    u  - motor torque input
%    J  - motor inertia
%    Ts - sampling time
%
%  Outputs:
%    Jac - measurement Jacobian computed at x
%

%  Copyright 2016-2017 The MathWorks, Inc.

% System parameters
J  = varargin{2};   % System innertia

% Jacobian
J = [ ...
    1 0;
    -x(2)/J -x(1)/J];
end
