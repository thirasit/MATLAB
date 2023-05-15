% plotLCResults Helper script for plotting the results of the lane
% change example.
%
%   This is a helper function for example purposes and may be removed or
%   modified in the future.
%
% The function assumes that the example outputs the Simulink log, logsout,
% containing the following elements: reference_signal, steering angle, and states

% Copyright 2019 The MathWorks, Inc.

%% Get the data from simulation
reference_signal = out.logsout.getElement('reference_signal');
steering_angle = out.logsout.getElement('steering angle');
states = out.logsout.getElement('states');

Xstate = states.Values.Data(:,3);
Ystate = states.Values.Data(:,4);

ref_y = reference_signal.Values.Data(:,2:31,:);
Yref = ref_y(2,1,1);

for i = 2:size(reference_signal.Values.Data,3)
    Yref = [Yref; ref_y(2,1,i)];
end
tmax = states.Values.time(end);

%% Plot lane change performance results 
figure('Name','Lane Change Performance','position',[100 100 720 600])

% steering angle
subplot(2,1,1)
plot(steering_angle.Values.time,steering_angle.Values.Data,'r')
grid on
xlim([0,tmax])
legend('Steering angle','location','NorthEast')
title('Steering angle')
xlabel('time (sec)')
ylabel('steering angle (rad)')

% lateral position
subplot(2,1,2)
plot(states.Values.Time,Ystate,'blue');
hold on;
plot(steering_angle.Values.time,Yref,'r');
grid on
xlim([0,tmax])
legend('Lateral Position of Ego Vehicle','Planned Trajectory','location','NorthEast')
title('Tracking performance')
xlabel('time (sec)')
ylabel('lateral position (m)')
