%%% Function Defining Current Density in Coil for 3-D Model
function f3D = windingCurrent3D(region,~)
[TH,~,~] = cart2pol(region.x,region.y,region.z);
f3D = -5E6*[sin(TH); -cos(TH); zeros(size(TH))];
end