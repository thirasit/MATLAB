function plotLKAPerformance(logsout)
% A helper function for plotting the results of the LKA demo.
%
%   This is a helper function for example purposes and may be removed or
%   modified in the future.
%
% The function assumes that the demo outputs the Simulink log, logsout,
% containing the following elements: lateral_deviation, relative_yaw_angle,
% abd steering_angle.

% Copyright 2017 The MathWorks, Inc.

%% Get the data from simulation
lateral_deviation = logsout.getElement('lateral_deviation');    % lateral deviation
relative_yaw_angle = logsout.getElement('relative_yaw_angle');  % relative yaw angle
steering_angle = logsout.getElement('steering_angle');          % steering angle

%% Plot the results
figure('Name','Controller Performance','position',[100 100 720 600]);
% lateral deviation
subplot(3,1,1);
plot(lateral_deviation.Values.time,lateral_deviation.Values.Data,'b','LineWidth',2);grid on;
legend('lateral deviation','location','NorthEast');
title('Lateral deviation')
xlabel('time (sec)')
ylabel('lateral deviation (m)')
% relative yaw angle
subplot(3,1,2);
plot(relative_yaw_angle.Values.time,relative_yaw_angle.Values.Data,'b','LineWidth',2);grid on;
legend('relative yaw angle','location','NorthEast');
title('Relative yaw angle')
xlabel('time (sec)')
ylabel('relative yaw angle (rad)')
% steering angle
subplot(3,1,3);
plot(steering_angle.Values.time,steering_angle.Values.Data,'b','LineWidth',2);grid on;
legend('steering angle','location','SouthEast');
title('Steering angle')
xlabel('time (sec)')
ylabel('steering angle (rad)')



