function y = pdmMotorModelMeasurementFcn(x,varargin)
%PDMMOTORMODELMEASUREMENTFCN
%
% Measurement equations for a motor with friction as a state
%
%  y = pdmMotorModelMeasurementFcn(x0,u,J,Ts)
%
%  Inputs:
%    x  - motor state with elements [angular velocity; friction] 
%    u  - motor torque input
%    J  - motor inertia
%    Ts - sampling time
%
%  Outputs:
%    y - motor measurements with elements [angular velocity; angular acceleration]
%

%  Copyright 2016-2017 The MathWorks, Inc.

% Extract data from inputs
u  = varargin{1};   % Input
J  = varargin{2};   % System innertia

% Output equation
y = [...
    x(1); ...
    (u-x(1)*x(2))/J];
end