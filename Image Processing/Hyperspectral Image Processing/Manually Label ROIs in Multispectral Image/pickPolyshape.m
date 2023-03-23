%%% Supporting Functions
% The pickPolyshape helper function performs these tasks:
% 1. Creates a customizable rectangular ROI.
% 2. Calculates the x- and y-coordinates of the corners of the ROI.
% 3. Transforms the intrinsic coordinates of the ROI to world coordinates.
function [xWorld,yWorld] = pickPolyshape(R)   
    roi = drawrectangle(Color="r");
    x1 = roi.Position(1);
    y1 = roi.Position(2);
    x2 = x1 + roi.Position(3);
    y2 = y1 + roi.Position(4);
    [xWorld,yWorld] = intrinsicToWorld(R,[x2 x1 x1 x2 x2],[y1 y1 y2 y2 y1]);
end