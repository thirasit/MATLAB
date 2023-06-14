function mpcLKAplot(logsout)
%% Get the data from simulation
steering_angle = logsout.getElement('steering_angle');
lateral_deviation = logsout.getElement('lateral_deviation');
relative_yaw_angle = logsout.getElement('relative_yaw_angle');


%% Plot the results
figure('position',[100 100 960 800])

% lateral deviation
subplot(3,1,1)
plot(lateral_deviation.Values.time,lateral_deviation.Values.Data,'b')
grid on
legend('lateral deviation','location','SouthEast')
title('Lateral deviation')
xlabel('time (sec)')
ylabel('lateral deviation (m)')

% relative yaw angle
subplot(3,1,2)
plot(relative_yaw_angle.Values.time,relative_yaw_angle.Values.Data,'b')
grid on
legend('relative yaw angle','location','SouthEast')
title('Relative yaw angle')
xlabel('time (sec)')
ylabel('relative yaw angle (rad)')

% steering angle
subplot(3,1,3)
plot(steering_angle.Values.time,steering_angle.Values.Data,'b')
grid on
legend('steering angle','location','SouthEast')
title('Steering angle')
xlabel('time (sec)')
ylabel('steering angle (rad)')

