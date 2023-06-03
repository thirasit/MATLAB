function f = obstaclePlotInitialCondition(x0,obstacle,laneWidth,lanes)
% Create figure
f = figure;

% Plot the Ego vehicle.
carLength = 5;
carWidth = 2;
X0 = x0(1);
Y0 = x0(2);
plot(X0,Y0,'gx'); hold on; grid on;
rectangle('Position',[X0-carLength/2,Y0 - carWidth/2,carLength,carWidth]);

% Plot the static obstacle.
plot(obstacle.X,obstacle.Y,'rx');
rectangle('Position',[obstacle.rrX,obstacle.rrY,obstacle.Length,obstacle.Width]);

% Plot the safe zone around obstacle.
rectangle('Position',[obstacle.rrSafeX,obstacle.rrSafeY,...
    (obstacle.safeDistanceX)*2,(obstacle.safeDistanceY)*2],...
    'LineStyle','--','EdgeColor','r');

% Plot the lanes.
X = [0;50;100];
Y = [2;2;2];
line(X,Y,'LineStyle','--','Color','b' );
X = [0;50;100];
Y = [-2;-2;-2];
line(X,Y,'LineStyle','--','Color','b' );

% Reset the axis.
axis([0 100 -laneWidth*lanes/2 laneWidth*lanes/2]);
xlabel('X');
ylabel('Y');
title('Obstacle Avoidance Maneuver');


