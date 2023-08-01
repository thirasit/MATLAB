%% Constraints on Linear Combinations of Inputs and Outputs
% You can constrain linear combinations of plant input and output variables.
% For example, you can constrain a particular manipulated variable (MV) to be greater than a linear combination of two other MVs.

% The general form of such constraints is:

figure
imshow("Opera Snapshot_2023-07-31_083938_www.mathworks.com.png")
axis off;

% As an example, consider an MPC controller for a double-integrator plant with mixed input/output constraints.

%%% Create Initial MPC Controller
% The basic setup of the MPC controller includes:
% - A double integrator as the prediction model
% - Prediction horizon of 20
% - Control horizon of 20
% - Input constraints: $- 1 \le u\left( t \right) \le 1$
plant = tf(1,[1 0 0]);
Ts = 0.1;
p = 20;
m = 20;
mpcobj = mpc(plant,Ts,p,m);
mpcobj.MV = struct('Min',-1,'Max',1);

%%% Define Mixed Input/Output Constraints
% Constrain the sum of the input u(t) and output y(t) must be nonnegative and smaller than 1.2:

figure
imshow("mpcmixedconstraints_eq09567401808870112255.png")
axis off;

% To impose this combined (mixed) I/O constraint, formulate it as a set of inequality constraints involving $u\left( t \right)$ and $y\left( t \right)$.

figure
imshow("mpcmixedconstraints_eq17597253268694455925.png")
axis off;

% To define these constraints using the setconstraint function, set the constraint constants as follows:

figure
imshow("mpcmixedconstraints_eq14304708454108056021.png")
axis off;

setconstraint(mpcobj,[1;-1],[1;-1],[1.2;0]);

%%% Simulate Controller
% Simulate closed-loop control of the linear plant model in Simulink.
% The controller mpcobj is specified in the MPC Controller block.
mdl = 'mpc_mixedconstraints';
open_system(mdl)
sim(mdl)

figure
imshow("mpcmixedconstraints_01.png")
axis off;

figure
imshow("mpcmixedconstraints_02.png")
axis off;

figure
imshow("mpcmixedconstraints_03.png")
axis off;

figure
imshow("mpcmixedconstraints_04.png")
axis off;

% The MPC controller keeps the sum $u+y$ between 0 and 1.2 while tracking the reference signal, $r = 1$.
bdclose(mdl)
