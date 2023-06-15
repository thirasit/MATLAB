function plotLKAResults(scenario,logsout,driverPath)

plotDriverPath = true;
if nargin < 3
    plotDriverPath = false;
end
% Overlay driver path and actual path
figure('Color','white');
ax1 = subplot(1,2,1);
ax2 = subplot(1,2,2);

plot(scenario,'Parent',ax1)
ylim([-50 200])

plot(scenario,'Parent',ax2)
xlim([20 145])
ylim([-20 30])

if plotDriverPath
    line(ax1,driverPath(:,1),driverPath(:,2),'Color','blue','LineWidth',1)
    line(ax2,driverPath(:,1),driverPath(:,2),'Color','blue','LineWidth',1)
    ax1.Title = text(0.5,0.5,'Road and driver path');
    ax2.Title = text(0.5,0.5,'Driver asssisted at curvature change');
else
    ax1.Title = text(0.5,0.5,'Road and assisted path');
    ax2.Title = text(0.5,0.5,'Lane keeping assist at curvature change');
end

line(ax1,logsout.get('position').Values.Data(:,1),...
     logsout.get('position').Values.Data(:,2),...
     'Color','red','LineWidth',1)
line(ax2,logsout.get('position').Values.Data(:,1),...
     logsout.get('position').Values.Data(:,2),...
     'Color','red','LineWidth',1)

