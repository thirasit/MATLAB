function nlobjTracking = createMPCForTrackingVPP(pTracking)
% create nlmpc object for tracking.

% Copyright 2019-2022 The Mathworks Inc

%%
mpcverbosity('off');

% mpc initialization
nx = 3;
ny = 3;
nu = 2;
nlobjTracking = nlmpc(nx,ny,nu);

% vehicle dynamics
nlobjTracking.Model.StateFcn = "parkingVehicleStateFcnVPP";
nlobjTracking.Jacobian.StateFcn = "parkingVehicleStateJacobianFcnVPP";

% mpc settings
Ts = 0.1;
nlobjTracking.Ts = Ts;
nlobjTracking.PredictionHorizon = pTracking;
nlobjTracking.ControlHorizon = pTracking;

% mpc limits
nlobjTracking.MV(1).Min = -6.5;
nlobjTracking.MV(1).Max = 6.5;
nlobjTracking.MV(2).Min = -pi/4;
nlobjTracking.MV(2).Max = pi/4;

% mpc weights
nlobjTracking.Weights.OutputVariables = [1,1,3]; 
nlobjTracking.Weights.ManipulatedVariablesRate = [0.1,0.05];

end