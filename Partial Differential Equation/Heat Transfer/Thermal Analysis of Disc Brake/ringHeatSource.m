%%% Heat Source Functions for Static Heat Sources
function F = ringHeatSource(region,state,driveline)

% Parameters ---------

R = 0.115; % Distance from center of disc to center of braking pad
r = 0.025; % Radius of braking pad
xc = 0.15; % x-coordinate of center of disc
yc = 0.15; % y-coordinate of center of disc

% Braking power in watts
power = interp1(driveline.tout,driveline.heatFlow,state.time);
Tambient = 30; % Ambient temperature (for convection)
h = 10; % Convection heat transfer coefficient in W/m^2*K
Tf = 2.5; % Time in seconds
%--------------------


x = region.x; 
y = region.y;

F = h*(Tambient - state.u); % Convection

if isnan(state.time)
    F = nan(1,numel(x));
end


if state.time < Tf
    rad = sqrt((x - xc).^2 + (y - yc).^2);

    idx = rad >= R-r & rad <= R+r;

    area = pi*( (R+r)^2 - (R-r)^2 );
    F(1,idx) = 0.5*power/area;  % 0.5 because there are 2 faces
end

end
