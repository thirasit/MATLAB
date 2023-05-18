function FlyingRobotPlotPlanning(Info,Ts)
% FlyingRobotPlotPlanning displays the optimal trajectory of the flying
% robot.

% Copyright 2018-2021 The MathWorks, Inc.

Xopt = Info.Xopt;
MVopt = Info.MVopt;
fprintf('Optimal fuel consumption = %10.6f\n',Info.Cost*Ts)

%% Examine solution
t = Info.Topt;
figure;
states = {'x','y','theta','vx','vy','omega'};
for i = 1:size(Xopt,2)
    subplot(3,2,i)
    plot(t,Xopt(:,i),'o-')
    title(states{i})
end
figure;
MVopt(end,:) = 0; % replace the last row u(k+p) with 0
for i = 1:4
    subplot(4,1,i)
    stairs(t,MVopt(:,i),'o-')
    axis([0 max(t) -0.1 1.1])
    title(sprintf('Thrust u(%i)', i));
end
figure;
hold off
for ct=1:size(Xopt,1)
    lf = [cos(atan(0.5)+Xopt(ct,3))*0.5 sin(atan(0.5)+Xopt(ct,3))*0.5];
    rf = [cos(atan(-0.5)+Xopt(ct,3))*0.5 sin(atan(-0.5)+Xopt(ct,3))*0.5];
    lr = [cos(pi-atan(0.5)+Xopt(ct,3))*0.5 sin(pi-atan(0.5)+Xopt(ct,3))*0.5];
    rr = [cos(pi-atan(-0.5)+Xopt(ct,3))*0.5 sin(pi-atan(-0.5)+Xopt(ct,3))*0.5];
    patch([lf(1) rf(1) rr(1) lr(1)]+Xopt(ct,1),[lf(2) rf(2) rr(2) lr(2)]+Xopt(ct,2),'y','FaceAlpha',0.5,'LineStyle',':');
    line([lf(1) rf(1)]+Xopt(ct,1),[lf(2) rf(2)]+Xopt(ct,2),'color','r');
    hold on
end
xlabel('x')
ylabel('y')
title('Optimal Trajectory')
