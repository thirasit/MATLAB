function labelIDs = realPixelLabelIDs()
% Return the label IDs corresponding to each class.
%
% The CamVid dataset has 32 classes. Group them into 5 classes.
%
% The 5 classes are:
%   "Road", "Background", "Pavement", "Sky" and
%   "Car".
%
% CamVid pixel label IDs are provided as RGB color values. Group them into
% 5 classes and return them as a cell array of M-by-3 matrices. The
% original CamVid class names are listed alongside each RGB value. 

labelIDs = { ...
% Road
[
128 064 128; ... % "Road"
128 000 192; ... % "LaneMkgsDriv"
192 000 064; ... % "LaneMkgsNonDriv"
]


% "Background"
[
000 128 064; ... % "Bridge"
128 000 000; ... % "Building"
064 192 000; ... % "Wall"
000 000 064; ... % "TrafficCone"
064 000 064; ... % "Tunnel"
192 000 128; ... % "Archway"
064 064 128; ... % "Fence"
000 064 064; ... % "TrafficLight"
192 128 128; ... % "SignSymbol"
192 192 128; ... % "Column_Pole"
128 128 000; ... % "Tree"
192 192 000; ... % "VegetationMisc"
128 128 064; ... % "Misc_Text"
064 064 000; ... % "Pedestrian"
192 128 064; ... % "Child"
064 000 192; ... % "CartLuggagePram"
064 128 064; ... % "Animal"
192 000 192; ... % "MotorcycleScooter"
000 128 192; ... % "Bicyclist"
192 064 128; ... % "Train"
128 064 064; ... % "OtherMoving"
000 000 000; ... % " Void"
]

% "Pavement"
[
064 192 128; ... % "ParkingBlock"
128 128 192; ... % "RoadShoulder"
000 000 192; ... % "Sidewalk"
]

% "Sky"
[
128 128 128; ... % "Sky"
]

% "Car"
[
064 000 128; ... % "Car"
064 128 192; ... % "SUVPickupTruck"
192 128 192; ... % "Truck_Bus"
]

};
end