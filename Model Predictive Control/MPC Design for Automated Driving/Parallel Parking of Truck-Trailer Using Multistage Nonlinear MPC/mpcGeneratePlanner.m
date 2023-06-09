function planner = mpcGeneratePlanner(truckDimensions,wallLength,wallWidth)
% Genrate multistage Nonlinear MPC as path planner for parking of the
% truck-trailer system. The planner has a prediction horizon of 20 s and sample
% time of 1 s.

% Copyright 2021 The MathWorks, Inc.

%% Parameters
pPlanning = 20;
Ts = 1;
nx = 4;
nu = 2;
planningObj = nlmpcMultistage(pPlanning,nx,nu);
planningObj.Ts = Ts;
planningObj.UseMVRate = true;
stateParameters = [truckDimensions.M1;truckDimensions.L1;truckDimensions.L2];
stageParameters = [truckDimensions.M1;truckDimensions.L1;truckDimensions.L2;...
                   truckDimensions.W1;truckDimensions.W2;wallLength;wallWidth];

%% Model
planningObj.Model.StateFcn = "stateFcnTruck";
planningObj.Model.StateJacFcn = "stateJacobianFcnTruck";
planningObj.Model.ParameterLength = numel(stateParameters);

%% Constraints on MVs
planningObj.MV(1).Min = -pi/4;  % Minimum steering angle
planningObj.MV(1).Max =  pi/4;  % Maximum steering angle
planningObj.MV(2).Max =  5;     % Maximum velocity
planningObj.MV(2).Min = -5;     % Minimum velocity
planningObj.MV(1).RateMin = -0.6;
planningObj.MV(1).RateMax = 0.6;
planningObj.MV(2).RateMin = -2;
planningObj.MV(2).RateMax = 2;

%% Constraints on states
planningObj.States(4).Min = -pi/2;  % Internal angle lower bound
planningObj.States(4).Max =  pi/2;  % Internal angle upper bound

%% Cost (low velocity preferred)
for ct = 1:pPlanning
    planningObj.Stages(ct).CostFcn = "costFcnPlanner";
    planningObj.Stages(ct).CostJacFcn = "costJacobianPlanner";
    planningObj.Stages(ct).ParameterLength = numel(stageParameters);
end

%% Inequality constraints (obstable avoiding)
for ct = 2:pPlanning
    planningObj.Stages(ct).IneqConFcn = "inEqConFcnPlannerParallel";
end

%% Terminal states
planningObj.Model.TerminalState = zeros(4,1);

%% Validate
simdata = getSimulationData(planningObj,'TerminalState');
simdata.StateFcnParameter = stateParameters;
simdata.StageParameter = repmat(stageParameters,pPlanning,1);
simdata.TerminalState = zeros(4,1);

xTest = [-16 0 0 0]';uTest = [0.22 -3]';
validateFcns(planningObj,xTest,uTest,simdata);

%% Results
planner.mpcobj = planningObj;
planner.sampleTime = planningObj.Ts;
planner.horizon = planningObj.p;
planner.modelParameters = stateParameters;
planner.envParameters = stageParameters;
planner.simdata = simdata;
