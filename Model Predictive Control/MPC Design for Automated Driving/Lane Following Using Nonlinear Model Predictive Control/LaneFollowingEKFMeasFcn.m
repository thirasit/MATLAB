function [y] = LaneFollowingEKFMeasFcn(x)
% Measurement function used by the Extended Kalman Filter block.
%
% Inputs:
%           x: Current state values
% Outputs:
%           y: Output vector - [Vx e1 e2+x_od]

% Copyright 2018 The MathWorks, Inc.

%#codegen
y = [x(3);x(5);x(6)+x(7)];


