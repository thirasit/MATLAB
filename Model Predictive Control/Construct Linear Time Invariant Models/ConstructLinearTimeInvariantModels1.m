%% Construct Linear Time Invariant Models
% Model Predictive Control Toolbox™ software supports the same LTI model formats as does Control System Toolbox™ software. 
% You can use whichever is most convenient for your application and convert from one format to another. 
% For more details, see Basic Models.

%%% Transfer Function Models
% A transfer function (TF) relates a particular input/output pair of (possibly vector) signals.
% For example, if u(t) is a plant input and y(t) is an output, the transfer function relating them might be:
figure
imshow("Opera Snapshot_2023-04-14_103852_www.mathworks.com.png")
axis off;

% This TF consists of a numerator polynomial, s+2, a denominator polynomial, s2+s+10, and a delay, which is 1.5 time units here.
% You can define G using Control System Toolbox tf function:
Gtf1 = tf([1 2], [1 1 10],'OutputDelay',1.5)

%%% Zero/Pole/Gain Models
% Like the TF format, the zero/pole/gain (ZPK) format relates an input/output pair of (possibly vector) signals.
% The difference is that the ZPK numerator and denominator polynomials are factored, as in
figure
imshow("Opera Snapshot_2023-04-14_104111_www.mathworks.com.png")
axis off;

% (zeros and/or poles are complex numbers in general).
% You define the ZPK model by specifying the zero(s), pole(s), and gain as in
poles = [-0.3, -0.1+0.7*i, -0.1-0.7*i];
Gzpk1 = zpk(-0.45,poles,2.5);

%%% State-Space Models
% The state-space format is convenient if your model is a set of LTI differential and algebraic equations.

% The linearized model of a Continuously Stirred Tank Reactor (CSTR) is shown in CSTR Model.
% In the model, the first two state variables are the concentration of reagent (here referred to as CA and measured in kmol/m3) and the temperature of the reactor (here referred to as T, measured in K), while the first two inputs are the coolant temperature (Tc, measured in K, used to control the plant), and the inflow feed reagent concentration CAf, measured in kmol/m3, (often considered as unmeasured disturbance).

% A state-space model can be defined as follows:
A = [   -5  -0.3427; 
     47.68    2.785];
B = [    0   1
       0.3   0];
C = [0 1
     1 0];
D = zeros(2,2);
CSTR = ss(A,B,C,D);

% This defines a continuous-time state-space model stored in the variable CSTR.
% The model is continuous time because no sampling time was specified, and therefore a default sampling value of zero (which means that the model is continuous time) is assumed.
% You can also specify discrete-time state-space models.
% You can specify delays in both continuous-time and discrete-time models.

%%% LTI Object Properties
% The ss function in the last line of the above code creates a state-space model, CSTR, which is an LTI object.
% The tf and zpk commands described in Transfer Function Models and Zero/Pole/Gain Models also create LTI objects.
% Such objects contain the model parameters as well as optional properties.

%%% Additional LTI Input and Output Properties
% The following code sets some optional input and outputs names and properties for the CSTR state-space object:

CSTR.InputName = {'T_c', 'C_A_f'};  % set names of input signals
CSTR.OutputName = {'T', 'C_A'};     % set names of output signals
CSTR.StateName = {'C_A', 'T'};      % set names of state variables

% assign input and output signals to different MPC categories
CSTR=setmpcsignals(CSTR,'MV',1,'UD',2,'MO',1,'UO',2)

% The first three lines specify labels for the input, output and state variables.
% The next four specify the signal type for each input and output.
% The designations MV, UD, MO, and UO mean manipulated variable, unmeasured disturbance, measured output, and unmeasured output.
% (See MPC Signal Types for definitions.)
% For example, the code specifies that input 2 of model CSTR is an unmeasured disturbance.
% The last line causes the LTI object to be displayed, generating the following lines in the MATLAB® Command Window:

% CSTR =
 
%  A = 
%            C_A        T
%   C_A       -5  -0.3427
%   T      47.68    2.785
 
%  B = 
%          T_c  C_A_f
%   C_A      0      1
%   T      0.3      0
 
%  C = 
%       C_A    T
%   T      0    1
%   C_A    1    0
 
%  D = 
%          T_c  C_A_f
%   T        0      0
%   C_A      0      0
 
%Input groups:              
%       Name        Channels
%    Manipulated       1    
%    Unmeasured        2    
                           
%Output groups:            
%       Name       Channels
%     Measured        1    
%    Unmeasured       2    
                          
%Continuous-time state-space model.

% For CSTR, the default Model Predictive Control Toolbox assumptions are incorrect. You must set its InputGroup and OutputGroup properties, as illustrated in the above code, or modify the default settings when you load the model into MPC Designer.
% Use setmpcsignals to make type definition. For example:
CSTR = setmpcsignals(CSTR,'UD',2,'UO',2);
