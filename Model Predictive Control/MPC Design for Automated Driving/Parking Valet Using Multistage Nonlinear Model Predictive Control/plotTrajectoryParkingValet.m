function plotTrajectoryParkingValet(xHistory,uHistory)
% Plot results for parking velt

% Copyright 2019 The MathWorks, Inc.

xLength = size(xHistory,1);
uLength = size(uHistory,1);

if xLength~=uLength
    xHistory = xHistory';
    uHistory = uHistory';
end

%% 
% Plot the closed-loop response.
figure
title('Vehicle states')
subplot(3,1,1)
plot(xHistory(:,1))
grid on
xlabel('time')
ylabel('x position (m)')
subplot(3,1,2)
plot(xHistory(:,2))
grid on
xlabel('time')
ylabel('y position (m)')
subplot(3,1,3)
plot(rad2deg(xHistory(:,3)))
grid on
xlabel('time')
ylabel('yaw angle (deg)')

figure;
title('Vehicle control inputs')
subplot(2,1,1)
stairs(uHistory(:,1))
grid on
xlabel('time')
ylabel('speed (m/s)')
subplot(2,1,2)
stairs(rad2deg(uHistory(:,2)))
grid on
xlabel('time')
ylabel('steering (deg)')
