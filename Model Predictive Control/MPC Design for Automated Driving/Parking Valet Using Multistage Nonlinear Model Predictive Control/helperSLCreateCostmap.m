function costmap = helperSLCreateCostmap()
% helperSLCreateCostmap create a costmap for a parking lot.
% This file is modified from the "AutomatedParkingValetSimulinkExample".

% Copyright 2019 The MathWorks, Inc.

%%
% Load occupancy maps corresponding to 3 layers - obstacles, road
% markings, and used spots.
mapLayers.StationaryObstacles = imread('stationary.bmp');
mapLayers.RoadMarkings        = imread('road_markings.bmp');
mapLayers.ParkedCars          = imread('parked_cars.bmp');

% Combine map layers struct into a single vehicleCostmap.
combinedMap = mapLayers.StationaryObstacles + mapLayers.RoadMarkings + ...
    mapLayers.ParkedCars;
combinedMap = im2single(combinedMap);

res = 0.5; % meters
costmap = vehicleCostmap(combinedMap, 'CellSize', res);
end