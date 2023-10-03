function dmap = domainAdaptationColorMap()
% The helper function domainAdaptationColorMap defines the colormap.
dmap = [
    % "Road"
    128 064 128; ... % "Road"
    
    % "Building"
    070 070 070; ... % "Building"
    
    % "Pavemennt"
    060 040 222; ... % "Pavemennt"
    
    % "Sky"
    070 130 180; ... % "Sky"
    
    % "Car"
    064 000 128; ... % "Car"
    ]; 

% Normalize between [0 1].
dmap = dmap ./ 255;
end