function nlobj = helperCreateNLmpcObjLC
% Part of set up script for the Lane Change Example
%
% This function designs a multistage nonlinear MPC controller.
%
%   This is a helper for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019-2021 The MathWorks, Inc.

%%
% Create a nonlinear MPC controller object with 5 states and 1 input.
nlobj = nlmpcMultistage(30,5,1);

%%
% Specify the controller sample time.
nlobj.Ts = 0.1;

%% 
% Enable MVRate because it is used in the cost function
nlobj.UseMVRate = true;

%%
% Specify the state function for the nonlinear plant model and its
% Jacobian.
nlobj.Model.StateFcn = 'vehicleStateFcnLC';
nlobj.Model.StateJacFcn = 'vehicleStateJacFcnLC';

%%
% Set the constraints for manipulated variables.
nlobj.MV(1).Min = -1.13;   % Minimum steering angle -65
nlobj.MV(1).Max = 1.13;    % Maximum steering angle 65

%%
% Specify stage cost function. The first, second, and fifth states are
% allowed to float, with and emphasis given more to tracking the lateral
% position (Y) and producing a smooth driving experience.
for ct = 1:31
    nlobj.Stages(ct).CostFcn = 'vehicleCostFcnLC';
    nlobj.Stages(ct).ParameterLength = 2;
end

%%
% Validate the prediction model functions at an arbitrary operating point
% using the validateFcns command
x0 = [0.1 0.5 200 -1.8 0.5];
u0 = 0.4;
simdata = getSimulationData(nlobj);
simdata.StageParameter = repmat([200;-2],31,1);
validateFcns(nlobj,x0,u0,simdata);
