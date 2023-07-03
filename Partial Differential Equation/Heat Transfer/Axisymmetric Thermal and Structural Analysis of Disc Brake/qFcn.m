%%% Heat Flux Function
% This helper function computes the transient value of the heat flux from the pad to the disc.
% It uses the empirical formula from [1].
function q = qFcn(r,s)
alphad = 1.44E-5; % Diffusivity of disc
Kd = 51; % Conductivity of disc
rhod = 7100; % Density of disc
cpd = Kd/rhod/alphad; % Specific heat capacity of disc

alphap = 1.46E-5; % Diffusivity of pad
Kp = 34.3; % Conductivity of pad
rhop = 4700; % Density of pad
cpp = Kp/rhop/alphap; % Specific heat capacity of pad

f = 0.5; % Coefficient of friction
omega0 = 88.464; % Initial angular velocity
ts = 3.96; % Stopping time
p0 = 1.47E6*(64.5/360); % Pressure only spans 64.5 deg occupied by pad

omegat = omega0*(1 - s.time/ts); % Angular speed over time

eta = sqrt(Kd*rhod*cpd)/(sqrt(Kd*rhod*cpd) + sqrt(Kp*rhop*cpp));
q = (eta)*f*omegat*r.r*p0;
end