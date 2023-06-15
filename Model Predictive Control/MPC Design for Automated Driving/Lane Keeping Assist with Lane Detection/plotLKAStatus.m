function plotLKAStatus(logsout)
%plotLKASimulation A helper function for plotting the results of the LKA
% demo.
%   This is a helper function for example purposes and may be removed or
%   modified in the future.
%
% The function assumes that the demo outputs the Simulink log, logsout,
% containing the following elements: 
%   status                   lane keep assist status
%   departure_detected       departure detection status
%   assisted_steer           lane keep assist steering angle
%   driver_steer             driver steering angle
%   left_assist_offset       threshold of left lateral offset for LKA
%   left_lateral_offset      left lateral offset
%   right_assist_offset      threshold of right lateral offset for LKA
%   right_lateral_offset     right lateral offset

% Copyright 2017 The MathWorks, Inc.

%% Get the data from simulation
status = logsout.getElement('status');                          
departure_detected = logsout.getElement('departure_detected');  
assisted_steer = logsout.getElement('assisted_steer');          
driver_steer = logsout.getElement('driver_steer');              
left_assist_offset = logsout.getElement('left_assist_offset');  
left_lateral_offset = logsout.getElement('left_lateral_offset');
right_lateral_offset = logsout.getElement('right_lateral_offset');
right_assist_offset = logsout.getElement('right_assist_offset');

%% Plot the results
figure('Name','Controller Status','position',[100 100 720 600]);
% lateral offset
subplot(3,1,1);
plot(left_lateral_offset.Values.time,left_lateral_offset.Values.Data,'b','LineWidth',2);grid on;
ylim([-3,3]);
title('Left and right lateral offset')
xlabel('time (sec)')
ylabel ('lateral offset (m)')
hold on;
plot(left_assist_offset.Values.time,left_assist_offset.Values.Data,'b:','LineWidth',2);grid on;
hold on;
plot(right_assist_offset.Values.time,right_assist_offset.Values.Data,'r:','LineWidth',2);grid on;
hold on;
plot(right_lateral_offset.Values.time,right_lateral_offset.Values.Data,'r','LineWidth',2);grid on;
legend('left assist offset','left lateral offset','right assist offset','right lateral offset','location','SouthEast');
% detection status
subplot(3,1,2);
stairs(status.Values.time,status.Values.Data,'r','LineWidth',2);grid on;
ylim([-0.1,1.1]);
title('Status')
xlabel('time (sec)')
hold on;
stairs(departure_detected.Values.time,departure_detected.Values.Data,'b','LineWidth',2);grid on;
legend('LKA status','departure detected','location','SouthEast');
% steering
subplot(3,1,3);
plot(driver_steer.Values.time,driver_steer.Values.Data,'b','LineWidth',2);grid on;
title('Driver and assisted steering angle')
xlabel('time (sec)')
ylabel('steering angle (rad)')
hold on;
plot(assisted_steer.Values.time,assisted_steer.Values.Data,'r','LineWidth',2);grid on;
legend('driver steer','assisted steer','location','SouthEast');

