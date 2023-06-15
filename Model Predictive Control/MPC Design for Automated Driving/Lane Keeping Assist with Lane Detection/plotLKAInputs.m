function plotLKAInputs(scenario,driverPath)

% Overlay driver path and actual path

figure('Color','white');
ax1 = subplot(1,2,1);
ax2 = subplot(1,2,2);

plot(scenario,'Parent',ax1)
ylim([-50 200])

plot(scenario,'Parent',ax2)
xlim([20 145])
ylim([-20 30])

line(ax1,driverPath(:,1),driverPath(:,2),'Color','blue','LineWidth',1)
line(ax2,driverPath(:,1),driverPath(:,2),'Color','blue','LineWidth',1)
ax1.Title = text(0.5,0.5,'Road and driver path');
ax2.Title = text(0.5,0.5,'Driver asssisted at curvature change');


