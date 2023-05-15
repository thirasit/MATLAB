% This script shows the trajectory following performance in animation in
% the quadrotor path following example.

% Copyright 2019 The MathWorks, Inc.

figure('Name','QuadrotorAnimation');
hold on
for i=1:size(xHistory,1)
    clf;
    animateQuadrotor(time(i), xHistory(i,:));
    pause(Ts);    
end