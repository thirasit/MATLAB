%% Explicit MPC Control of a Single-Input-Single-Output Plant
% This example shows how to control a double integrator plant under input saturation in Simulink® using explicit MPC.
% For an example that controls a double integrator with a traditional (implicit) MPC controller, see Model Predictive Control of a Single-Input-Single-Output Plant.

%%% Define Plant Model
% The linear open-loop dynamic model is a double integrator.
plant = tf(1,[1 0 0]);

%%% Design MPC Controller
% Create the controller object with a sample period of 0.1 seconds, and prediction and control horizons of 10 and 3 steps respectively.
Ts = 0.1;
mpcobj = mpc(plant, Ts, 10, 3);

% Specify actuator saturation limits as manipulated variable constraints.
mpcobj.MV = struct('Min',-1,'Max',1);

%%% Explicit MPC
% The constraints divide the state space of the MPC controller into many polyhedral regions such that within each region the MPC control law is a specific affine-in-the-state-and-reference function, with coefficients depending on the region.
% Explicit MPC calculates all these regions, and their relative control laws, offline.
% Online, the controller just selects and applies the precomputed solution relative to the current region, so it does not have to solve a constrained quadratic optimization problem at each control step.
% For more information on explicit MPC, see Explicit MPC.

%%% Generate Explicit MPC Controller
% Explicit MPC executes the equivalent explicit piecewise affine version of the MPC control law defined by the traditional MPC controller.
% To generate an explicit MPC controller from a traditional MPC controller, you must specify the range for each controller state, reference signal, manipulated variable and measured disturbance.
% Doing so ensures that the quadratic programming problem is solved in the space defined by these ranges.
% If at run time one of these independent variables falls outside of its range, the controller returns an error status and sets the manipulated variables to their last values.
% Therefore, it is important that you do not underestimate these ranges.

% To generate suitable ranges, obtain some information on the controller states first.
% To display the controller initial states, use mpcstate.
mpcstate(mpcobj)

% As expected, the plant model used by the Kalman estimator has 2 states, and then there is one additional state needed to hold the last value of the manipulated variable.

% MPC controller states include states from plant model, disturbance model noise model, and last values of the manipulated variables, in that order.
% To create a range structure where you can specify the range for each state, reference, and manipulated variable, use generateExplicitRange.
range = generateExplicitRange(mpcobj);

% Setting the range of a state variable is sometimes difficult when the state does not correspond to a physical parameter.
% In that case, multiple runs of open-loop plant simulation with typical reference and disturbance signals, as well as model mismatches are recommended in order to collect data that reflect the ranges of states.
% For this example, overestimate the ranges as follows.
range.State.Min(:) = [-10;-10];
range.State.Max(:) = [10;10];

% Usually you know the practical range of the reference signals being used at the nominal operating point in the plant.
% The ranges used to generate an explicit MPC controller must be at least as large as the practical range.
range.Reference.Min = -2;
range.Reference.Max = 2;

% Specify the manipulated variable ranges.
% If the manipulated variables are constrained, the ranges used to generate the explicit MPC controller must be at least as large as these limits.
range.ManipulatedVariable.Min = -1.1;
range.ManipulatedVariable.Max = 1.1;

% Use generateExplicitMPC command to obtain an explicit MPC controller with the specified parameter ranges.
mpcobjExplicit = generateExplicitMPC(mpcobj, range)

% Use the simplify function with the 'exact' method to join pairs of regions whose corresponding gains are the same and whose union is a convex set.
% Doing so can reduce memory footprint of the explicit MPC controller without sacrificing any performance.
mpcobjExplicitSimplified = simplify(mpcobjExplicit, 'exact')

% The number of piecewise affine regions has been reduced.

%%% Plot Piecewise Affine Partition Along a Given Section
% You can plot a 2D section of the controller state space, and look at the regions in this section.
% For this example, plot the 2D section of the state space defined by the first and second state variables (load angle and angular velocity).
% To do so you must first create a plot structure in which you fix all the other states (and reference signals) to specific values within their respective ranges.

% To create a parameter structure where you can specify which 2-D section to plot afterwards, use the generatePlotParameters function.
plotpars = generatePlotParameters(mpcobjExplicitSimplified)

% In this example, you plot the first state variable against the second state variable.
% All the other parameters must be fixed at values within their respective ranges.
% Leave the state variables free to vary, by not specifying indexes.
plotpars.State.Index = [];
plotpars.State.Value = [];

% Specify index of the reference signal and fix it to a value of 0.
plotpars.Reference.Index = 1;
plotpars.Reference.Value = 0;

% Specify index of the manipulated variable and fix it to a value of 0.
plotpars.ManipulatedVariable.Index = 1;
plotpars.ManipulatedVariable.Value = 0;

% Use plotSection command to plot the 2-D section defined by the two free parameters. For more information, see plotSection.
plotSection(mpcobjExplicitSimplified, plotpars);
axis([-4 4 -4 4]);
grid
xlabel('State #1');
ylabel('State #2');

%%% Simulate Using mpcmove Function
% Compare closed-loop simulations for traditional implicit MPC and explicit MPC using the mpcmove and mpcmoveExplicit functions respectively.
% Initialize variables to store the closed-loop MPC responses.
N = round(5/Ts);
YY = zeros(N,1);
YYExplicit = zeros(N,1);
UU = zeros(N,1);
UUExplicit = zeros(N,1);

% Prepare the plant model used in simulation
sys = c2d(ss(plant),Ts);
xsys = [0;0];
xsysExplicit = xsys;

% To obtain a pointer to the internal states for both controllers, use mpcstate.
xmpc = mpcstate(mpcobj);
xmpcExplicit = mpcstate(mpcobjExplicitSimplified);

% Iteratively simulate the closed-loop response for both controllers.
for k = 1:N-1

    % update plant measurement
    ysys = sys.C*xsys;
    ysysExplicit = sys.C*xsysExplicit;

    % compute traditional MPC action
    u = mpcmove(mpcobj,xmpc,ysys,1);
    % compute explicit MPC action
    uExplicit = mpcmoveExplicit(mpcobjExplicit,xmpcExplicit,ysysExplicit,1);

    % store signals
    YY(k)=ysys;
    YYExplicit(k)=ysysExplicit;
    UU(k)=u;
    UUExplicit(k)=uExplicit;

    % update plant state
    xsys = sys.A*xsys + sys.B*u;
    xsysExplicit = sys.A*xsysExplicit + sys.B*uExplicit;
end

% Display norm of the differences between traditional and explicit controller signals.
fprintf('\nDifference between traditional and Explicit MPC responses using MPCMOVE command is %g\n',...
    norm(UU-UUExplicit)+norm(YY-YYExplicit));

%%% Simulate Using sim Function
% Compare closed-loop simulations between traditional and explicit MPC using the sim command.
N = 5/Ts;                      % number of simulation iterations
[y1,t1,u1] = sim(mpcobj,N,1);  % simulate with traditional MPC
[y2,t2,u2] = sim(mpcobjExplicitSimplified,N,1); % simulate with explicit MPC

% The simulation results are identical.
fprintf('\nDifference between traditional and Explicit MPC responses using SIM command is %g\n',...
    norm(u2-u1)+norm(y2-y1));

%%% Simulate Using Simulink
% Simulate the traditional MPC controller in Simulink.
% The MPC Controller block is configured to use mpcobj as its controller.
mdl = 'mpc_doubleint';
open_system(mdl)
sim(mdl)

figure
imshow("empcdoubleint_02.png")
axis off;

figure
imshow("empcdoubleint_03.png")
axis off;

figure
imshow("empcdoubleint_04.png")
axis off;

% Simulate the explicit MPC controller in Simulink.
% The Explicit MPC Controller block is configured to use mpcobjExplicitSimplified as its controller.
mdlExplicit = 'empc_doubleint';
open_system(mdlExplicit)
sim(mdlExplicit)

figure
imshow("empcdoubleint_05.png")
axis off;

figure
imshow("empcdoubleint_06.png")
axis off;

figure
imshow("empcdoubleint_07.png")
axis off;

figure
imshow("empcdoubleint_08.png")
axis off;

figure
imshow("empcdoubleint_09.png")
axis off;

% The closed-loop responses are identical.
fprintf('\nDifference between traditional and Explicit MPC responses in Simulink is %g\n',...
    norm(uExplicit-u)+norm(yExplicit-y));

% Close both simulink models.
bdclose(mdl)
bdclose(mdlExplicit)
