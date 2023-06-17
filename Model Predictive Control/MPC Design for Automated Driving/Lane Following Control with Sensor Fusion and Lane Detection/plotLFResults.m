function plotLFResults(logsout,time_gap,default_spacing)
% plotLFResults Helper function for plotting the results of the lane
% following example.
%
%   This is a helper function for example purposes and may be removed or
%   modified in the future.
%
% The function assumes that the example outputs the Simulink log, logsout,
% containing the following elements: acceleration, ego_velocity,
% driver_set_velocity, and relative_distance.

% Copyright 2018-2020 The MathWorks, Inc.


%% Get the data from simulation
ego_acceleration = logsout.getElement('ego_acceleration'); % acceleration of ego car
ego_velocity = logsout.getElement('ego_velocity'); % velocity of host car
driver_set_velocity = logsout.getElement('driver_set_velocity'); % driver-set velocity

relative_distance = logsout.getElement('relative_distance'); % actual distance
relative_velocity = logsout.getElement('relative_velocity'); % relative velocity
safe_distance = (ego_velocity.Values.Data*time_gap) + default_spacing;

lead_velocity = relative_velocity.Values.Data + ego_velocity.Values.Data; % lead velocity

lateral_deviation = logsout.getElement('lateral_deviation');          % lateral deviation
relative_yaw_angle = logsout.getElement('relative_yaw_angle');        % relative yaw angle
steering_angle = logsout.getElement('steering_angle');                % steering angle

tmax = ego_velocity.Values.time(end);

Collision = logsout.getElement('collision');      % collision

%% Plot the spacing control results
figure('Name','Spacing Control Performance','position',[100 100 720 600])

% velocity
subplot(4,1,1)
plot(ego_velocity.Values.time,ego_velocity.Values.Data,'r')
hold on;
plot(driver_set_velocity.Values.time,driver_set_velocity.Values.Data,'k--')
hold on
plot(ego_velocity.Values.time,lead_velocity,'b')
hold on
xlim([0,tmax])
grid on
legend('ego velocity','set velocity','lead velocity','location','NorthEast')
title('Velocity')
xlabel('time (sec)')
ylabel('m/s')

% distance
subplot(4,1,2)
plot(relative_distance.Values.time,relative_distance.Values.Data,'r')
hold on
plot(relative_distance.Values.time,safe_distance,'b')
grid on
xlim([0,tmax])
legend('actual distance','safe distance','location','NorthEast')
title('Distance between two cars')
xlabel('time (sec)')
ylabel('m')

% acceleration
subplot(4,1,3)
plot(ego_acceleration.Values.time,ego_acceleration.Values.Data,'r')
grid on
xlim([0,tmax])
ylim([-3.5,2.2])
legend('ego accel','location','NorthEast')
title('Acceleration')
xlabel('time (sec)')
ylabel('$m/s^2$','Interpreter','latex')

% collision status
subplot(4,1,4)
stairs(Collision.Values.time,Collision.Values.Data,'m')
grid on
xlim([0,tmax])
ylim([-0.2,1.2])
legend('collision status','location','NorthWest')
title('Collision status: 0 or 1')
xlabel('time (sec)')

%% Plot the lane following results
figure('Name','Lateral Control Performance','position',[835 100 720 600])

% lateral deviation
subplot(3,1,1)
plot(lateral_deviation.Values,'b')
grid on
xlim([0,tmax])
ylim([-0.2,0.2])
legend('lateral deviation','location','NorthEast')
title('Lateral deviation')
xlabel('time (sec)')
ylabel('lateral deviation (m)')

% relative yaw angle
subplot(3,1,2)
plot(relative_yaw_angle.Values,'b')
grid on
xlim([0,tmax])
legend('relative yaw angle','location','NorthEast')
title('Relative yaw angle')
xlabel('time (sec)')
ylabel('relative yaw angle (rad)')

% steering angle
subplot(3,1,3)
plot(steering_angle.Values.time,steering_angle.Values.Data,'b')
grid on
xlim([0,tmax])
legend('steering angle','location','SouthEast')
title('Steering angle')
xlabel('time (sec)')
ylabel('steering angle (rad)')

drawnow
