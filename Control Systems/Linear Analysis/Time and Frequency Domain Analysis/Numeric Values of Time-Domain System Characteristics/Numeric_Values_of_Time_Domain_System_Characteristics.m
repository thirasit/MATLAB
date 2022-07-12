%% Numeric Values of Time-Domain System Characteristics

% This example shows how to obtain numeric values of step response characteristics such as rise time, settling time, and overshoot using stepinfo. 
% You can use similar techniques with lsiminfo to obtain characteristics of the system response to an arbitrary input or initial conditions.

% Create a dynamic system model and get numeric values of the system’s step response characteristics.

H = tf([8 18 32],[1 6 14 24]);
data = stepinfo(H)

% The output is a structure that contains values for several step response characteristics. 
% To access these values or refer to them in other calculations, use dot notation. 
% For example, data.Overshoot is the overshoot value.

% Calculate the time it takes the step response of H to settle within 0.5% of its final value.

data = stepinfo(H,'SettlingTimeThreshold',0.005);
t05 = data.SettlingTime

% By default, stepinfo defines the settling time as the time it takes for the output to settle within 0.02 (2%) of its final value. 
% Specifying a more stringent 'SettlingTimeThreshold' of 0.005 results in a longer settling time.

% For more information about the options and the characteristics, see the stepinfo reference page.
