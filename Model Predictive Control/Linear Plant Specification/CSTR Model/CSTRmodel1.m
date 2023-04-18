%% CSTR Model
% The adiabatic continuous stirred tank reactor (CSTR) is a common chemical system in the process industry, and it is described extensively in [1].
% A single first-order exothermic and irreversible reaction, A → B, takes place in the vessel, which is assumed to be always perfectly mixed.
% The inlet stream of reagent A enters the tank at a constant volumetric rate.
% The product stream B exits continuously at the same volumetric rate, and liquid density is constant.
% Thus, the volume of reacting liquid is constant.
% The following figure shows a schematic diagram of the vessel and the surrounding cooling jacket.
figure
imshow("cstr_diagram.png")
axis off;

% The inputs of the CSTR model are arranged in the vector u(t) and are as follows.
% u1 — CAf, the concentration of reagent A in the inlet feed stream, measured in kmol/m3
% u2 — Tf, the temperature of the inlet feed stream, measured in K
% u3 — Tc, the temperature of the jacket coolant, measured in K

% The first two inputs (concentration and temperature of the inlet reagent feed stream, sometimes also indicated as CAi and Ti, respectively) are normally assumed to be constant unmeasured disturbances, while the third (temperature of the coolant) is the control input used to control the process.
% Note that the diagram is a simplified sketch; in reality the coolant flow surrounds the whole reactor jacket, and not just the bottom of it.

% The states of the model are arranged in the vector x(t).
% x1 — CA, the concentration of reagent A in the reactor, measured in kmol/m3
% x2 — T, the temperature in the reactor, measured in K

%%% Nonlinear Model
% The CSTR system is modeled using basic mass balance and energy conservation principles.
% The change of the concentration of reagent A in the vessel per time unit can be modeled as follows.
figure
imshow("Opera Snapshot_2023-04-18_062104_www.mathworks.com.png")
axis off;

% The first term, where V is the reactor volume and F is the volumetric flow rate, expresses the concentration difference between the inlet and the stream.
% The second term is the reaction rate per unit of volume, and it is described by the Arrhenius rate law, as follows.
figure
imshow("Opera Snapshot_2023-04-18_062211_www.mathworks.com.png")
axis off;

% Here:
% E is the activation energy.
% R is the Boltzmann ideal gas constant.
% T is the temperature in the reactor.
% k0 is an unknown nonthermal constant.

% The rate law states that the reaction rate increases exponentially with the absolute temperature.
% Similarly, using the energy balance principle, and assuming constant volume in the reactor, the temperature change per unit of time can be modeled as follows.
figure
imshow("Opera Snapshot_2023-04-18_062341_www.mathworks.com.png")
axis off;

% Here, the first and third terms describe changes due to the inlet feed stream temperature Tf and jacket coolant temperature Tc, respectively.
% The second term represents the influence on the reactor temperature caused by the chemical reaction in the vessel.

% In this equation:
% ΔH is the heat of the reaction, per mole.
% Cp is a heat capacity coefficient.
% ρ is a density coefficient.
% U is an overall heat transfer coefficient.
% A is the area for the heat exchange (coolant/vessel interface area).

% A Simulink® representation of this nonlinear reactor model is available in the models mpc_cstr_plant, CSTR_OpenLoop, and CSTR_INOUT.
% It is used in several examples illustrating how to linearize nonlinear models and how to use linear, adaptive, gain-scheduled, and nonlinear MPC to control a nonlinear plant.

% Parameters of the Nonlinear CSTR Simulink Model
figure
imshow("Opera Snapshot_2023-04-18_062554_www.mathworks.com.png")
axis off;

% In the model, the initial value of CA is 8.5698 kmol/m3 and the initial value for T is 311.2639 K.
% This operating point is an equilibrium when the inflow feed concentration CAf is 10 kmol/m3, the inflow feed temperature Tf is 300 K, and the coolant temperature Tc is 292 K.

% In the example Non-Adiabatic Continuous Stirred Tank Reactor: 
% MATLAB File Modeling with Simulations in Simulink (System Identification Toolbox), you use the above equations to estimate the last four parameters when the disturbance inputs CAf and Tf stay around to 10 kmol/m3 and 298 K, respectively, and the control input Tc ranges from 273 to 322 K.
% The first state variable, CA, ranges from 0 to 10 kmol/m3 and the second one, T, ranges from 310 to 390 K.
% The values of the last four parameters are estimated to be 11,854, 35,588,869, 500.7095, and 150.1275, respectively, with the same units as in the table.

%%% Linear Model
% A linearized model of the CSTR, in which Tf does not deviate from its nominal condition, can be represented by the following linear differential equations.
figure
imshow("Opera Snapshot_2023-04-18_062822_www.mathworks.com.png")
axis off;

% Here, the primes (for example, C′A) denote a deviation from the nominal steady-state condition at which the model has been linearized.
% The constants aij and bij are the coefficients of the Jacobian matrices (normally indicated as A and B) with respect to state and input, respectively.
% A symbolic expression of the majority of these coefficients is given in [1].

% Since measurement of reactant concentrations is often difficult, a common assumption is that T is the only measured output, while CA is unmeasured.
% For similar reasons, CAf is commonly assumed to be an unmeasured disturbance.
% In general, Tc, is the manipulated variable used to control the reactor.

% The linearized model fits the general state-space format
figure
imshow("Opera Snapshot_2023-04-18_062918_www.mathworks.com.png")

% The following code shows how to define such a model for some specific values of the aij and bij constants:
A = [   -5  -0.3427; 
     47.68    2.785];
B = [    0   1
       0.3   0];
C = flipud(eye(2));
D = zeros(2);
CSTR = ss(A,B,C,D);

% These values correspond to a linearization around an operating point in which CA is 2 kmol/m3, T is 373 K, CAf is 10 kmol/m3, Tf is 300 K, and Tc is 299 K.
% See Linearization Using MATLAB Code for more information.

% You can specify the input, output, and state names for your CSTR model.
% Also, you can specify the input and output signals types.
CSTR.InputName = {'T_c', 'C_A_f'};  % set names of input signals
CSTR.OutputName = {'T', 'C_A'};     % set names of output signals
CSTR.StateName = {'C_A', 'T'};      % set names of state variables

% assign input and output signals to different MPC categories
CSTR=setmpcsignals(CSTR,'MV',1,'UD',2,'MO',1,'UO',2);

% Here, MV, UD, MO, and UO stand for "Manipulated Variable," "Unmeasured Disturbance," "Measured Output," and "Unmeasured Output," respectively.
% View the CSTR model and its properties.
CSTR

% In summary, in this linearized model, the first two state variables are the concentration of reagent and the temperature of the reactor, while the first two inputs are the coolant temperature and the inflow feed reagent concentration.

% For details on how to obtain this linear model, see the two examples in Linearize Simulink Models.
% In the first example the linearization is done in MATLAB®, while in the second one it is done using Model Linearizer (Simulink Control Design) in Simulink.

%%% References
% [1] Bequette, B., Process Dynamics: Modeling, Analysis and Simulation, Prentice-Hall, 1998, Module 8, pp. 641-660.
