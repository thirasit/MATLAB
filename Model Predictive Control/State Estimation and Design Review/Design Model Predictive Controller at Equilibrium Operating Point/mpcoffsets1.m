%% Design Model Predictive Controller at Equilibrium Operating Point
% This example shows how to design a model predictive controller with nonzero nominal values.

% The plant model is obtained by linearization of a nonlinear plant in Simulink® at a nonzero steady-state operating point.

%%% Linearize Nonlinear Plant Model
% The nonlinear plant is implemented in the Simulink model mpc_nloffsets and linearized at the default operating condition using the linearize function from Simulink Control Design.

% Create an operating point specification for the current model initial conditions.
plant_mdl = 'mpc_nloffsets';
op = operspec(plant_mdl);

% Compute the operating point for these initial conditions.
[op_point, op_report] = findop(plant_mdl,op);

% Extract nominal state, output, and input values from the computed operating point.
x0 = [op_report.States(1).x;op_report.States(2).x];
y0 = op_report.Outputs.y;
u0 = op_report.Inputs.u;

% Linearize the plant at the initial conditions.
plant = linearize(plant_mdl,op_point);

%%% Design MPC Controller
% Create an MPC controller object with a specified sample time Ts, prediction horizon 20, and control horizon 3.
Ts = 0.1;
mpcobj = mpc(plant,Ts,20,3);

% Set the nominal values in the controller.
mpcobj.Model.Nominal = struct('X',x0,'U',u0,'Y',y0);

% Set the output measurement noise model (white noise, zero mean, standard deviation = 0.1).
mpcobj.Model.Noise = 0.1;

% Set the manipulated variable constraint.
mpcobj.MV.Max = 0.2;

%%% Simulate Using Simulink
% Specify the reference value for the output signal.
r0 = 1.5*y0;

% Open and simulate the model.
mdl = 'mpc_offsets';
open_system(mdl)
sim(mdl)

figure
imshow("mpcoffsets_01.png")
axis off;

figure
imshow("mpcoffsets_02.png")
axis off;

figure
imshow("mpcoffsets_03.png")
axis off;

%%% Simulate Using sim Command
% Simulate the controller.
Tf = round(10/Ts);
r = r0*ones(Tf,1);
[y1,t1,u1,x1,xmpc1] = sim(mpcobj,Tf,r);

% Plot and compare the simulation results.
subplot(1,2,1)
plot(y.time,y.signals.values,t1,y1,t1,r)
legend('Nonlinear','Linearized','Reference')
title('output')
grid

subplot(1,2,2)
plot(u.time,u.signals.values,t1,u1)
legend('Nonlinear','Linearized')
title('input')
grid

bdclose(plant_mdl)
bdclose(mdl)
