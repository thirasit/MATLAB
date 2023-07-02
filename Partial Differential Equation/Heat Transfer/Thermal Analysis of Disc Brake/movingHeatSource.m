%%% Heat Source Functions for Moving Heat Sources
function F = movingHeatSource(region,state)

% Parameters ---------

R = 0.115; % Distance from center of disc to center of braking pad
r = 0.025; % Radius of braking pad
xc = 0.15; % x-coordinate of center of disc
yc = 0.15; % y-coordinate of center of disc

T = 0.05; % Period of 1 revolution of disc

power = 35000; % Braking power in watts
Tambient = 30; % Ambient temperature (for convection)
h = 10; % Convection heat transfer coefficient in W/m^2*K
%--------------------

theta = 2*pi/T*state.time;

xs = xc + R*cos(theta);
ys = yc + R*sin(theta);

x = region.x; 
y = region.y;

F = h*(Tambient - state.u); % Convection


if isnan(state.time)
    F = nan(1,numel(x));
end

idx = (x - xs).^2 + (y - ys).^2 <= r^2;

F(1,idx) = 0.5*power/(pi*r.^2);  % 0.5 because there are 2 faces

end
