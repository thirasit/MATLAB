%% Convert Discrete-Time System to Continuous Time
% This example shows how to convert a discrete-time system to continuous time using d2c, 
% and compare the results using two different interpolation methods.

% Convert the following second-order discrete-time system to continuous time using the zero-order hold (ZOH) method:

figure
imshow("ConvertDiscreteTimeSystemtoContinuousTime_01.png")

G = zpk(-0.5,[-2,5],1,0.1);
Gcz = d2c(G)

% When you call d2c without specifying a method, the function uses ZOH by default. 
% The ZOH interpolation method increases the model order for systems that have real negative poles. 
% This order increase occurs because the interpolation algorithm maps real negative poles in the z domain 
% to pairs of complex conjugate poles in the s domain.

% Convert G to continuous time using the Tustin method.

Gct = d2c(G,'tustin')

% In this case, there is no order increase.

% Compare frequency responses of the interpolated systems with that of G.

figure
bode(G,Gcz,Gct)
legend('G','Gcz','Gct')

% In this case, the Tustin method provides a better frequency-domain match between the discrete system and the interpolation. 
% However, the Tustin interpolation method is undefined for systems with poles at z = -1 (integrators), 
% and is ill-conditioned for systems with poles near z = 1.
