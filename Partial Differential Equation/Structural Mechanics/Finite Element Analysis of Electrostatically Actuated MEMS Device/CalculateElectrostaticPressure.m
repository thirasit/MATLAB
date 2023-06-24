%% Electrostatic Pressure Function
% The electrostatic pressure on the movable electrode is given by

%figure
%imshow("Opera Snapshot_2023-06-23_115417_www.mathworks.com.png")
%axis off;

function ePressure = ...
 CalculateElectrostaticPressure(elecResults,structResults,location)
% Function to compute electrostatic pressure.
% structuralBoundaryLoad is used to specify
% the pressure load on the movable electrode.
% Inputs:
% elecResults: Electrostatic FEA results
% structResults: Mechanical FEA results (optional)
% location: The x,y coordinate
% where pressure is obtained
%
% Output:
% ePressure: Electrostatic pressure at location
%
% location.x : The x-coordinate of the points
% location.y : The y-coordinate of the points
xq = location.x;
yq = location.y;

% Compute the magnitude of the electric field
% from the potential difference.
[gradx,grady] = evaluateGradient(elecResults,xq,yq);
absE = sqrt(gradx.^2 + grady.^2);

% The permittivity of vacuum is 8.854*10^-12 farad/meter.
epsilon0 = 8.854e-12;

% Compute the magnitude of the electric flux density.
absD0 = epsilon0*absE;
absD = absD0;

% If structResults (deformation) is available,
% update the charge density along the movable electrode.
if ~isempty(structResults)
 % Displacement of the movable electrode at position x
 intrpDisp = interpolateDisplacement(structResults,xq,yq);
 vdisp = abs(intrpDisp.uy);
 G = 2e-6; % Gap 2 micron
 absD = absD0.*G./(G-vdisp);
end

% Compute the electrostatic pressure.
ePressure = absD.^2/(2*epsilon0);

end
