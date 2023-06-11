function plotACCScenario

scenario = helperScenarioAuthoring(500, false);
figure('Color','white');
ax1 = subplot(1,2,1);
ax2 = subplot(1,2,2);

% plot with full road
plot(scenario,'Parent',ax1,'Centerline','on','Waypoints','off','RoadCenters','off');

% plot zoomed in
plot(scenario,'Parent',ax2,'Centerline','on','Waypoints','off','RoadCenters','off');
xlim([300 450])
ylim([-350 -250])



