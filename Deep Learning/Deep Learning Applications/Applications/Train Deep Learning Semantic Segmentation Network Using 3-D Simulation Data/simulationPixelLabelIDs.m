function labelIDs = simulationPixelLabelIDs()
% Return the label IDs corresponding to each class.
%
% The simulation dataset has 8 classes. Group them into 5 classes.
%
% The 5 classes are:
%   "Road", "Background", "Pavement", "Sky" and
%   "Car".
%
% Simulation pixel label IDs are provided as RGB color values. Group them into
% 5 classes and return them as a cell array of M-by-3 matrices. The
% original simulation class names are listed alongside each RGB value. Note
% that the Other/Void class are excluded below.

labelIDs = { ...
    
% Road
[
128 064 128; ... % "Road"
]


% "Background"
[
070 070 070; ... % "Building"
107 142 035; ... % "Trees"
255 150 000; ... % "Traffic Lights"
153 153 153; ... % "Lights"
]

% "Pavement"
[
244 035 232; ... % "Pavement"
]


% "Sky"
[
000 000 000; ... % "Sky"
]

% "Car"
[
000 000 225; ... % "Car"
]

};
end