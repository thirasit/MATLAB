function hTruckPlot = helperCreatePlotHandle(pose,truckDimension,steer,axesHandle)
%helperCreatePlotHandle plot a truck with one trailer

% Copyright 2021 The MathWorks, Inc.

truckShapes = helperTruckPolyshape(pose,truckDimension,steer);

bodyShape = truckShapes(1:2);
axles = truckShapes(3:5);
wheels = truckShapes(6:11);
hitch = truckShapes(12);

% Plot shapes
color = [0.0968 0.5145 0.88];
hShape = plot(axesHandle,bodyShape, ...
    'FaceColor',color,'EdgeColor',color,'AlignVertexCenters','on', ...
    'FaceAlpha',0.5);

hAxlesWheels = plot(axesHandle,[axles wheels hitch],'FaceColor','k', ...
    'FaceAlpha',1);

hTruckPlot = [hShape hAxlesWheels];
