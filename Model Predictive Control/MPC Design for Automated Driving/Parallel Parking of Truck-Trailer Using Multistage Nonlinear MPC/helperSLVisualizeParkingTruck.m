function helperSLVisualizeParkingTruck(pose,steer,truckDimensions)
% Create and initalize visualizers for a truck with one trailer system and
% obstacles for parallel parking.

% Copyright 2021 The MathWorks, Inc.

persistent axesHandle truckPlotHandle

pose(3) = rad2deg(pose(3));
pose(4) = rad2deg(pose(4));
steer = rad2deg(steer);

if isempty(axesHandle) || ~isvalid(axesHandle)
    %Initialize figure
    fh = figure('Visible','on','Position',[0 100 600 600]);
    fh.Name = 'Parallel Parking of Truck-trailer System';
    fh.NumberTitle = 'off';
    axesHandle = axes(fh);
    legend(axesHandle,'off');
    axis(axesHandle,'equal');
    title(axesHandle,'Parking Environment');
    hold(axesHandle,'on');
    
    axesHandle.XLim = [-30 10];
    axesHandle.YLim = [-30 50];
      
    % post processing of figure
    obstacles = createObstacles();
    for ct = 1:numel(obstacles)
        [~,obsObj] = show(obstacles{ct});
        obsObj.EdgeAlpha = 0;       
    end
end
% Plot vehicle
if isempty(truckPlotHandle) || any(~isvalid(truckPlotHandle))
    truckPlotHandle = helperCreatePlotHandle(pose,truckDimensions,steer,axesHandle);
    fh.Visible = 'on';
else
    truckShapes = helperTruckPolyshape(pose,truckDimensions,steer);
    for n = 1 : numel(truckPlotHandle)
        truckPlotHandle(n).Shape = truckShapes(n);
    end
end
plot(axesHandle,pose(1),pose(2),'.','color','r')
drawnow('limitrate');
end

%% local function
function obstacles = createObstacles()
% Obstacles
wallLength = 20;
wallWidth = 10;

    obs1 = collisionBox(wallWidth,wallLength,0);
    T1 = trvec2tform([-5,-25, 0]);
    obs1.Pose = T1;

    obs2 = collisionBox(wallWidth,wallLength,0);
    T2 = trvec2tform([-5,25, 0]);
    obs2.Pose = T2;

    obs3 = collisionBox(wallWidth,3*wallLength,0);
    T3 = trvec2tform([-25,0, 0]);
    obs3.Pose = T3;

    obs4 = collisionBox(wallWidth/2,30,0);
    T4 = trvec2tform([-2.5,0, 0]);
    obs4.Pose = T4;

    obstacles = {obs1,obs2,obs3,obs4};
end