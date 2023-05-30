function y = getPassivityOutput(x,tau)
% This is the output function of the passivity constraint for the
% two-link robot manipulator example. 
%
% Inputs of this function:
%       x: joint angles and velocities. 
%       tau: torque.
% Outputs of this function:
%       y: passivity output.

% Copyright 2022 The MathWorks, Inc.

x3 = x(3); % q1dot
x4 = x(4); % q2dot
y = [x3;x4];
