%% Specify Multi-Input Multi-Output Plants
% Most MPC applications involve plants with multiple inputs and outputs.
% You can use ss, tf, and zpk to represent a MIMO plant model.
% For example, consider the following model of a distillation column [1], which has been used in many advanced control studies:

figure
imshow("Opera Snapshot_2023-04-14_111522_www.mathworks.com.png")
axis off;

% Outputs y1 and y2 represent measured product purities.
% The controller manipulates the inputs, u1 and u2, to hold each output at a specified setpoint.
% These inputs represent the flow rates of reflux and reboiler steam, respectively.
% Input u3 is a measured feed flow rate disturbance.

% The model consists of six transfer functions, one for each input/output pair.
% Each transfer function is the first-order-plus-delay form often used by process control engineers.

% Specify the individual transfer functions for each input/output pair.
% For example, g12 is the transfer function from input u1 to output y2.
g11 = tf( 12.8, [16.7 1], 'IOdelay', 1.0,'TimeUnit','minutes');
g12 = tf(-18.9, [21.0 1], 'IOdelay', 3.0,'TimeUnit','minutes');
g13 = tf(  3.8, [14.9 1], 'IOdelay', 8.1,'TimeUnit','minutes');
g21 = tf(  6.6, [10.9 1], 'IOdelay', 7.0,'TimeUnit','minutes');
g22 = tf(-19.4, [14.4 1], 'IOdelay', 3.0,'TimeUnit','minutes');
g23 = tf(  4.9, [13.2 1], 'IOdelay', 3.4,'TimeUnit','minutes');

% Define a MIMO system by creating a matrix of transfer function models.
DC = [g11 g12 g13
      g21 g22 g23];

% Define the input and output signal names and specify the third input as a measured input disturbance.
DC.InputName = {'Reflux Rate','Steam Rate','Feed Rate'};
DC.OutputName = {'Distillate Purity','Bottoms Purity'};
DC = setmpcsignals(DC,'MD',3);

% Review the resulting system.
DC

%%% References
% [1] Wood, R. K., and M. W. Berry, Chem. Eng. Sci., Vol. 28, pp. 1707, 1973.
