function plotAndAnimateParkingRRT(p,xRef,xTrackHistory,uTrackHistory)
% Plot and Animate results for parking with RRT and nonlinear MPC.

% Copyright 2019 The MathWorks, Inc.

%% 
% animate
timeLength = size(xTrackHistory,2);
for ct = 1:timeLength
    helperSLVisualizeParking(xTrackHistory(:,ct)', uTrackHistory(2,ct));
    pause(0.05);
end
%% Tracking performance
figure;
num = p+1;
% x
subplot(3,1,1)
plot(xRef(:,1),'b')
hold on
plot(xTrackHistory(1,1:num),'r:','LineWidth',2)
grid on
xlabel('sample')
ylabel('x position (m)')
legend('RRT','NLMPC')
% y
subplot(3,1,2)
plot(xRef(:,2),'b')
hold on
plot(xTrackHistory(2,1:num),'r:','LineWidth',2)
grid on
xlabel('sample')
ylabel('y position (m)')
legend('RRT','NLMPC')
% yaw
subplot(3,1,3)
plot(xRef(:,3),'b')
hold on
plot(xTrackHistory(3,1:num),'r:','LineWidth',2)
grid on
xlabel('sample')
ylabel('yaw angle (rad)')
legend('RRT','NLMPC')


%% Control inputs
figure;
title('Vehicle control inputs')
subplot(2,1,1)
stairs(uTrackHistory(1,:))
grid on
xlabel('sample')
ylabel('speed (m/s)')
subplot(2,1,2)
stairs(rad2deg(uTrackHistory(2,:)))
grid on
xlabel('sample')
ylabel('steering (deg)')

% Analysis
e1 = norm(xTrackHistory(2,1:num)-xRef(:,2)',inf);
e2 = norm(xTrackHistory(2,1:num)-xRef(:,2)',inf);
e3 = rad2deg(norm(xTrackHistory(3,1:num)-xRef(:,3)',inf));
fprintf('Tracking error infinity norm in x (m), y (m) and theta (deg): %2.4f, %2.4f, %2.4f\n', e1, e2,e3);
vFinal = uTrackHistory(1,end);
deltaFinal = rad2deg(uTrackHistory(2,end));
fprintf('Final control inputs of speed (m/s) and steering angle (deg): %2.4f, %2.4f\n', vFinal,deltaFinal);

