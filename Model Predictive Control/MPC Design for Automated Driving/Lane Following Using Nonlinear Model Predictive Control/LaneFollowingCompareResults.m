function LaneFollowingCompareResults(logsout1,logsout2)
% Plot and compare results for nonlinear and adaptive mpc. 

%% Get the data from simulation
% for nonlinear MPC
[e1_nmpc,e2_nmpc,delta_nmpc,accel_nmpc,vx_nmpc] = getData(logsout1);
% for adaptive MPC
[e1_ampc,e2_ampc,delta_ampc,accel_ampc,vx_ampc] = getData(logsout2);

%% Plot results. 
figure; % lateral results
% steering angle
subplot(3,1,1);
hold on;
grid on;
plot(delta_nmpc.Values.time,delta_nmpc.Values.Data);
plot(delta_ampc.Values.time,delta_ampc.Values.Data);
legend('Nonlinear MPC','Adaptive MPC');
title('Steering Angle (u2) vs Time');
xlabel('Time(s)');
ylabel('steering angle(radians)');
hold off;
% lateral deviation
subplot(3,1,2);
hold on;
grid on;
plot(e1_nmpc.Values.time,e1_nmpc.Values.Data);
plot(e1_ampc.Values.time,e1_ampc.Values.Data);
legend('Nonlinear MPC','Adaptive MPC');
title('Lateral Deviation (e1) vs Time');
xlabel('Time(s)');
ylabel('Lateral Deviation(m)');
hold off;
% relative yaw angle
subplot(3,1,3);
hold on;
grid on;
plot(e2_nmpc.Values.Time,e2_nmpc.Values.Data);
plot(e2_ampc.Values.Time,e2_ampc.Values.Data);
legend('Nonlinear MPC','Adaptive MPC');
title('Relative Yaw Angle (e2) vs Time');
xlabel('Time(s)');
ylabel('Relative Yaw Angle(radians)');
hold off;

figure; % longitudinal results
% acceleration
subplot(2,1,1);
hold on;
grid on;
plot(accel_nmpc.Values.time,accel_nmpc.Values.Data);
plot(accel_ampc.Values.time,accel_ampc.Values.Data);
legend('Nonlinear MPC','Adaptive MPC');
title('Acceleration (u1) vs Time');
xlabel('Time(s)');
ylabel('Acceleration(m/s^2)');
hold off;
% longitudinal velocity
subplot(2,1,2);
hold on;
grid on;
plot(vx_nmpc.Values.Time,vx_nmpc.Values.Data);
plot(vx_ampc.Values.Time,vx_ampc.Values.Data);
legend('Nonlinear MPC','Adaptive MPC');
title('Velocity (Vy) vs Time');
xlabel('Time(s)');
ylabel('Velocity(m/s)');
hold off;

%% Local function: Get data from simulation
function [e1,e2,delta,accel,vx] = getData(logsout)
e1 = logsout.getElement('Lateral Deviation');    % lateral deviation
e2 = logsout.getElement('Relative Yaw Angle');   % relative yaw angle
delta = logsout.getElement('Steering');          % steering angle
accel = logsout.getElement('Acceleration');      % acceleration of ego car
vx = logsout.getElement('Longitudinal Velocity');% velocity of host car