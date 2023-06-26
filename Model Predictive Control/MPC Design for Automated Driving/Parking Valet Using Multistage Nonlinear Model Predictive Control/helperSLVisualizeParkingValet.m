function helperSLVisualizeParkingValet(pose, steer, costmapStruct)
% This function creates and initalize visualizers for ego and obstacles for
% parking. This file is adapted from the "AutomatedParkingValetSimulinkExample".

% Copyright 2019 The MathWorks, Inc.

persistent vehicleBodyHandle axesHandle vehicleDims costmap

pose(3) = rad2deg(pose(3));
steer = rad2deg(steer);

if isempty(vehicleDims)
    vehicleDims = vehicleDimensions;
end

%%
if isempty(costmap)
    % Initialize vehicleCostmap object
    costmap = vehicleCostmap(costmapStruct.Costs, ...
        'FreeThreshold',     costmapStruct.FreeThreshold, ...
        'OccupiedThreshold', costmapStruct.OccupiedThreshold, ...
        'MapLocation',       costmapStruct.MapExtent([1, 3]), ...
        'CellSize',          costmapStruct.CellSize);
   %   costmap = helperSLCreateCostmap();
end


%%
if isempty(axesHandle) || ~isvalid(axesHandle)     
    % Initialize figure  
    fh1=figure('Visible','off');
    fh1.Position = [680 140 635 450];%[435 200 1065 685];
    fh1.Name        = 'Automated Parking Valet';
    fh1.NumberTitle = 'off';
    axesHandle      = axes(fh1);
    plot(costmap, 'Parent', axesHandle, 'Inflation', 'off');
    legend off
    axis tight
    title(axesHandle, 'Parking garage');
    hold(axesHandle, 'on');
    
    axesHandle.XLim = costmap.MapExtent(1:2);
    axesHandle.YLim = costmap.MapExtent(3:4);
    
    width = 3.1;
    len = 6.2;
    % target parking lot for ego car
    rectangle('Position',[34.5 43.3 width len],'EdgeColor','g','LineWidth',2) % left corner (a,b), width c, height d
    % target point for ego car
    plot(36,45,'*','color','g')
    
    % target parking lot for ego car
    rectangle('Position',[25.7 0.5 width len],'EdgeColor','g','LineWidth',2) % left corner (a,b), width c, height d
    % target point for ego car
    plot(27.2,4.7,'*','color','g')
    
    %% post processing of figure
    obstacles = createObstacles();
    for ct = 1:numel(obstacles)
        show(obstacles{ct})
    end
    % Remove Line style for obstacles
    leftBorder = axesHandle.Children(1);
    leftBorder.LineStyle = 'none';
    leftBorder.FaceAlpha = 0.3;
    middleArea = axesHandle.Children(2);
    middleArea.LineStyle = 'none';
    middleArea.FaceAlpha = 0.3;
end

% Plot vehicle
if isempty(vehicleBodyHandle) || any(~isvalid(vehicleBodyHandle))
    vehicleBodyHandle = helperPlotVehicle(pose, vehicleDims, steer, 'Parent', axesHandle);
    % Vehicle color
    axesHandle.Children(7).FaceColor = 'b';
else
    vehicleShapes = helperVehiclePolyshape(pose, vehicleDims, steer);
    for n = 1 : numel(vehicleBodyHandle)
        vehicleBodyHandle(n).Shape = vehicleShapes(n);
    end
end

% Plot vehicle trajectory
plot(axesHandle,pose(1),pose(2),'.','color','r')

fh1.Visible = 'on';
drawnow('limitrate');

end

%% local function
function obstacles = createObstacles()
% Obstacles 

% parked cars in the bottom of garage
obs1 = collisionBox(2.9,4.8,0);
T1 = trvec2tform([23,3.55, 0]);
obs1.Pose = T1;

obs2 = collisionBox(2.9,4.8,0);
T2 = trvec2tform([31.5,3.55, 0]);
obs2.Pose = T2;

obs3 = collisionBox(2.9,4.8,0);
T3 = trvec2tform([40.5,3.55, 0]);
obs3.Pose = T3;

% parked cars in the top of garage
obs4 = collisionBox(2.9,4.8,0);
T4 = trvec2tform([23,46, 0]);
obs4.Pose = T4;

obs5 = collisionBox(2.6,4.8,0);
T5 = trvec2tform([27.3,46.5, 0]);
obs5.Pose = T5;

obs6 = collisionBox(2.9,4.8,0);
T6 = trvec2tform([53.5,46, 0]);
obs6.Pose = T6;

% garage border on the left
obs7 = collisionBox(0.5,50,0);
T7 = trvec2tform([0.25,25, 0]);
obs7.Pose = T7;

% parked area in the middle of garage
obs8 = collisionBox(48,13,0); % 48.5,13
T8 = trvec2tform([35.7,25, 0]);
obs8.Pose = T8;

obstacles = {obs1,obs2,obs3,obs4,obs5,obs6,obs7,obs8};
end

