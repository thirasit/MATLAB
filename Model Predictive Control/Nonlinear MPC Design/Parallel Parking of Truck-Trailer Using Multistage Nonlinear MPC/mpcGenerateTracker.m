function controller = mpcGenerateTracker(truckDimensions)
% Generate multistage Nonlinear MPC as trajectory tracking controller for
% parking of the truck-trailer system. The controller has a prediction
% horizon of 20 s and sample time of 0.1 s.

% Copyright 2021 The MathWorks, Inc.

%% Parameters
pTracking = 20;
Ts = 0.1;
nx = 4;
ny = 4;
nu = 2;
trackingObj = nlmpc(nx,ny,nu);
trackingObj.Ts = Ts;
trackingObj.PredictionHorizon = pTracking;
trackingObj.ControlHorizon = pTracking;

%% Model
trackingObj.Model.StateFcn = "stateFcnTruck";
trackingObj.Jacobian.StateFcn = "stateJacobianFcnTruck";

%% Model parameters
parasTracking = {[truckDimensions.M1,truckDimensions.L1,truckDimensions.L2]'};
trackingObj.Model.NumberOfParameters = numel(parasTracking);

%% Constraints on MVs
trackingObj.MV(1).Min = -pi/4; % Minimum steering angle
trackingObj.MV(1).Max = pi/4;  % Maximum steering angle
trackingObj.MV(2).Max = 5;     % Maximum velocity
trackingObj.MV(2).Min = -5;    % Minimum velocity
trackingObj.MV(1).RateMin = -0.1;
trackingObj.MV(1).RateMax = 0.1;
trackingObj.MV(2).RateMin = -0.2;
trackingObj.MV(2).RateMax = 0.2;

%% Scale factors
trackingObj.OV(1).ScaleFactor = 40;     % Range for x
trackingObj.OV(2).ScaleFactor = 40;     % Range for y
trackingObj.OV(3).ScaleFactor = 2*pi;   % Range for absolute angle
trackingObj.OV(4).ScaleFactor = pi;     % Equilibrium range for internal angle
trackingObj.MV(1).ScaleFactor = 0.5*pi; % Range for steering angle
trackingObj.MV(2).ScaleFactor = 10;     % Range for velocity

%% Weights
trackingObj.Weights.OutputVariables = [1 1 2 2];
trackingObj.Weights.ManipulatedVariables = [0 0];
trackingObj.Weights.ManipulatedVariablesRate = [.1 .1];

%% Constraints on internal angle
trackingObj.States(4).Min = -pi/2;
trackingObj.States(4).Max = pi/2;

%% Validate
trackingOptions = nlmpcmoveopt;
trackingOptions.Parameters = parasTracking;
xTest = [-16 0 0 0]';
uTest = [0.22 -3]';
validateFcns(trackingObj,xTest,uTest,{},parasTracking)

%% Results
controller.mpcobj = trackingObj;
controller.sampleTime = trackingObj.Ts;
controller.horizon = trackingObj.PredictionHorizon;
controller.options = trackingOptions;