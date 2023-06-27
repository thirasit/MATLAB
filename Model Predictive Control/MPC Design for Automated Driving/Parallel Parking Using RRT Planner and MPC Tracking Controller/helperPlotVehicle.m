function varargout = helperPlotVehicle(varargin)
% This file is the same as in the "AutomatedParkingValetSimulinkExample".

%helperPlotVehicle plot a vehicle.
%
%   helperPlotVehicle(vehiclePose, vehicleDims) plots a vehicle on the
%   current axes with vehiclePose specified as [x,y,theta] using dimensions
%   specified by vehicleDims specified as a vehicleDimensions object.
%
%   helperPlotVehicle(vehiclePose, vehicleDims, steer) additionally orients
%   the wheels using steering angle specified by steer (in degrees).
%
%   helperPlotVehicle(...,Name,Value) specifies additional name-value pair
%   arguments as described below:
%
%   'Parent'        Handle to an axes on which to display the path.
%
%   'Color'         Color of the vehicle, specified as an RGB triplet or a
%                   color name.
%
%   'DisplayName'   Name of the entry to show in the legend. If no name is
%                   specified, no entry is shown.
%
%                   Default: ''
%
%
%   Example - Plot a vehicle on costmap
%   -----------------------------------
%   % Load a costmap
%   data = load('parkingGarageCostmap.mat');
%   costmap = data.parkingGarageCostmap;
%
%   % Display the map
%   plot(costmap)
%
%   % Specify vehicle configuration
%   vehiclePose = [33 22 0];
%   steerAngle  = -15;
%   vehicleDims = vehicleDimensions();
%
%   % Display a vehicle on the map
%   hold on
%   helperPlotVehicle(vehiclePose, vehicleDims, steerAngle, ...
%       'DisplayName', 'car')
%
%   % Focus on vehicle
%   xlim(vehiclePose(1) + [-15 15])
%   ylim(vehiclePose(2) + [-10 10])
%
%
%   See also vehicleDimensions.

% Copyright 2017-2019 The MathWorks, Inc.

[vehiclePose, vehicleDims, steer, parent, displayName, color] = parseInputs(varargin{:});

carShapes = helperVehiclePolyshape(vehiclePose, vehicleDims, steer);

bodyShape = carShapes(1);
axles     = carShapes(2:3);
wheels    = carShapes(4:end);

% Do the right thing
hAx = newplot(parent);

if isempty(color)
    % Get the next color in ColorOrder
    color = hAx.ColorOrder( hAx.ColorOrderIndex,: );
    hAx.ColorOrderIndex = hAx.ColorOrderIndex+1;
end

% Check hold state
if ishold(hAx)
    oldState = 'on';
else
    oldState = 'off';
end

% Turn on hold
hold(hAx, 'on')
restoreHoldState = onCleanup(@()hold(hAx, oldState));

% Plot shapes
hShape = plot(hAx, bodyShape, 'DisplayName', displayName, ...
    'FaceColor', color, 'EdgeColor', color, 'AlignVertexCenters', 'on', ...
    'FaceAlpha', 0.5);

hAxlesWheels = plot(hAx, [axles wheels] , 'FaceColor', 'k', 'FaceAlpha', 1);

% Stack opaque axles, wheels on top of body so they don't appear to have
% alpha.
uistack(hAxlesWheels,'up');

% Add tags and userdata
hShape.Tag = 'vehicleBody';
hShape.UserData = [vehiclePose steer];
[hAxlesWheels(1:2).Tag]      = deal('vehicleAxles');
[hAxlesWheels(3:end).Tag]    = deal('vehicleWheels');

setupLegend(hShape, hAxlesWheels, displayName);

if nargout>0
    varargout{1} = [hShape hAxlesWheels];
end
end

%--------------------------------------------------------------------------
function setupLegend(hObjLeg, hObjNonLeg, displayName)

if isempty(displayName)
    hObjNonLeg = [hObjLeg(:); hObjNonLeg(:)];
else
    [hObjLeg.DisplayName] = deal(displayName);
end

turnOffLegend(hObjNonLeg);
end

%--------------------------------------------------------------------------
function turnOffLegend(hObj)

for n = 1 : numel(hObj)
    hObj(n).Annotation.LegendInformation.IconDisplayStyle = 'off';
end
end


%--------------------------------------------------------------------------
% Input parsing
%--------------------------------------------------------------------------
function [pose, dims, steer, parent, name, color] = parseInputs(varargin)

p = inputParser;
p.FunctionName = mfilename;

p.addRequired('vehiclePose',        @validatePose);
p.addRequired('vehicleDims',        @validateVehicleDimensions);
p.addOptional('steer',          0,  @validateSteer);
p.addParameter('DisplayName',   '', @validateDisplayName);
p.addParameter('Parent',        [], @validateParent);
p.addParameter('Color',         '', @validateColor);

p.parse(varargin{:});

res = p.Results;

pose    = res.vehiclePose;
dims    = res.vehicleDims;
steer   = res.steer;
parent  = res.Parent;
name    = res.DisplayName;
color   = res.Color;
end

%--------------------------------------------------------------------------
function validatePose(pose)
validateattributes(pose, {'single', 'double'}, ...
    {'real', 'row', 'numel', 3, 'finite'}, mfilename, 'vehiclePose');
end

%--------------------------------------------------------------------------
function validateVehicleDimensions(dims)

validateattributes(dims, {'vehicleDimensions'}, {'scalar'}, mfilename, ...
    'vehicleDims');
end

%--------------------------------------------------------------------------
function validateSteer(steer)
validateattributes(steer, {'single','double'}, {'real','scalar','finite'}, ...
    mfilename, 'steer');
end

%--------------------------------------------------------------------------
function validateDisplayName(name)

validateattributes(name, {'char','string'}, {'scalartext'}, ...
    mfilename, 'DisplayName');
end

%--------------------------------------------------------------------------
function tf = validateParent(parent)

tf = true;
if isempty(parent)
    return;
end

if ~ishghandle(parent) || ~strcmp(get(parent,'Type'), 'axes')
    error(message('driving:pathPlannerRRT:validParent'))
end
end

%--------------------------------------------------------------------------
function validateColor(color)

if ischar(color) || isstring(color)
    validateattributes(color, {'char','string'}, ...
        {'nonempty','scalartext'}, 'plot', 'Color');
    
    specOptions = {'red','green','blue','yellow','magenta',...
        'cyan','white','black','r','g','b','y','m','c','w','k'};
    
    % Find best match for the given color string
    validatestring(color, specOptions, 'plot', 'Color');
else
    validateattributes(color, {'double'}, ...
        {'nonempty','>=', 0, '<=', 1, 'size', [1 3]}, ...
        'plot', 'Color');
end
end