function helperSLVisualizeParking(pose, steer)
% This function creates and initalize visualizers for ego and obstacles for
% parking. This file is adapted from the "AutomatedParkingValetSimulinkExample".

% Copyright 2019 The MathWorks, Inc.

persistent vehicleBodyHandle axesHandle vehicleDims

pose(3) = rad2deg(pose(3));
steer = rad2deg(steer);

if isempty(vehicleDims)
    vehicleDims = vehicleDimensions;
end

if isempty(axesHandle) || ~isvalid(axesHandle)
    % Initialize figure
    fh1=figure('Visible','off','Position',[287 501 1412 480]);
    fh1.Name        = 'Automated Parallel Parking';
    fh1.NumberTitle = 'off';
    axesHandle      = axes(fh1);
    legend off
    axis equal;
    title(axesHandle, 'Parallel Parking');
    hold(axesHandle, 'on');
    
    axesHandle.XLim = [-20 20];
    axesHandle.YLim = [-7 7];
    
    width = 3.1;
    len = 6.2;
    
    % occupied parking lots
    rectangle('Position',[-1.5*len -0.5*width len width],'EdgeColor','r','FaceColor',[.8 .8 .8]) % left corner (a,b), width c, height d
    rectangle('Position',[0.5*len -0.5*width len width],'EdgeColor','r','FaceColor',[.8 .8 .8]) % left corner (a,b), width c, height d
    rectangle('Position',[-2.5*len -0.5*width len width],'EdgeColor','r','FaceColor',[.8 .8 .8]) % left corner (a,b), width c, height d
    rectangle('Position',[1.5*len -0.5*width len width],'EdgeColor','r','FaceColor',[.8 .8 .8]) % left corner (a,b), width c, height d
    
    % target parking lot for ego car
    rectangle('Position',[-0.5*len -0.5*width len width],'EdgeColor','g','LineWidth',2) % left corner (a,b), width c, height d
    % origin
    plot(0,0,'*','color','g')
    
    %% post processing of figure
    obstacles = createObstacles();
    for ct = 1:numel(obstacles)
        show(obstacles{ct})
    end
    % Remove Line style for yellow line and curbside
    ax = gca(fh1);
    yellowLine = ax.Children(1);
    yellowLine.LineStyle = 'none';
    curbside = ax.Children(2);
    curbside.LineStyle = 'none';
    
end

% Plot vehicle
if isempty(vehicleBodyHandle) || any(~isvalid(vehicleBodyHandle))
    vehicleBodyHandle = helperPlotVehicle(pose, vehicleDims, steer, 'Parent', axesHandle);
else
    vehicleShapes = helperVehiclePolyshape(pose, vehicleDims, steer);
    for n = 1 : numel(vehicleBodyHandle)
        vehicleBodyHandle(n).Shape = vehicleShapes(n);
    end
end
plot(axesHandle,pose(1),pose(2),'.','color','r')

fh1.Visible = 'on';
drawnow('limitrate');

end

%% local function
function obstacles = createObstacles()
% Obstacles (4 occupied parking lots, road curbside and yellow line)
obsLength = 6.2;
egoLength = 4.7;
egoWidth = 1.8;

obs1 = collisionBox(egoLength,egoWidth,0);
T1 = trvec2tform([-2*obsLength,0, 0]);
obs1.Pose = T1;

obs2 = collisionBox(egoLength,egoWidth,0);
T2 = trvec2tform([-obsLength,0, 0]);
obs2.Pose = T2;

obs3 = collisionBox(egoLength,egoWidth,0);
T3 = trvec2tform([obsLength,0, 0]);
obs3.Pose = T3;

obs4 = collisionBox(egoLength,egoWidth,0);
T4 = trvec2tform([2*obsLength,0, 0]);
obs4.Pose = T4;

obs5 = collisionBox(6*obsLength,0.5,0);
T5 = trvec2tform([0,-1.8, 0]);
obs5.Pose = T5;

obs6 = collisionBox(6*obsLength,0.5,0);
T6 = trvec2tform([0,5.65, 0]);
obs6.Pose = T6;


obstacles = {obs1,obs2,obs3,obs4,obs5,obs6};
end
