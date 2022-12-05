function x1 = pdmMotorModelStateFcn(x0,varargin)
%PDMMOTORMODELSTATEFCN
%
% State update equations for a motor with friction as a state
%
%  x1 = pdmMotorModelStateFcn(x0,u,J,Ts)
%
%  Inputs:
%    x0 - initial state with elements [angular velocity; friction] 
%    u  - motor torque input
%    J  - motor inertia
%    Ts - sampling time
%
%  Outputs:
%    x1 - updated states
%

%  Copyright 2016-2017 The MathWorks, Inc.

% Extract data from inputs
u  = varargin{1};   % Input
J  = varargin{2};   % System innertia
Ts = varargin{3};   % Sample time

% State update equation
x1 = [...
    x0(1)+Ts/J*(u-x0(1)*x0(2)); ...
    x0(2)];
end