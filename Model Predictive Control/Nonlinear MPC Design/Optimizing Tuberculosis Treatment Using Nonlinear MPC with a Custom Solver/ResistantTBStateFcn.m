function dxdt = ResistantTBStateFcn(x,u)
% Models evolution of resistant TB in a population of N individuals in
% continuous time. N is a constant of 30000.
%
% States:
%   x(1) = S, number of susceptible individuals
%   x(2) = T, number treated effectively and immune
%   x(3) = L2, latent with resistant TB, non-infections
%   x(4) = I1, infectious with typical TB
%   x(5) = I2, infectious with resistant TB
%
%   L1, latent with typical TB, non-infections, is N - sum(x).
%
% Manipulated variables (MVs):
%   u(1):  "case finding" - Effort expended to identify those needing
%           treatment. Relatively inexpensive.
%   u(2):  "case holding" - Effort to maintain effective treatment.
%           Relatively costly.
%
% Copyright 2018 The MathWorks, Inc.

N = 30000;          % total population
S = x(1); 
T = x(2); 
L2 = x(3); 
I1 = x(4);  
I2 = x(5);
L1 = N - sum(x);
Finding = u(1);
Holding = u(2);
% Parameters
beta1 = 13;         % infection rate of susceptible
beta2 = 13;         % infection rate of treated
betastar =0.029;    % infection rate of uninfected
mu = 0.0143;        % per capita natural death rate
d1 = 0;             % per capita death rate induced by typical TB
d2 = 0;             % per capita death rate induced by resistant TB
k1 = 0.5;           % rate individual in L1 becomes infectious
k2 = 1;             % rate individual in L2 becomes infectious
r1 = 2;             % treatment rate for individuals with latent, typical TB
r2 = 1;             % treatment rate for individuals with infectious, typical TB
p = 0.4;            % fraction of I1 not completing treatment
q = 0.1;            % fraction of I2 not completing treatment
% State equations
dxdt = zeros(5,1);
dxdt(1) = mu*N - (beta1*I1 + betastar*I2)*S/N - mu*S;
dxdt(2) = Finding*r1*L1 - mu*T + (1 - (1 - Holding)*(p + q))*r2*I1 - (beta2*T*I1 + betastar*T*I2)/N;
dxdt(3) = (1-Holding)*q*r2*I1 - (mu + k2)*L2 + betastar*(S + L1 + T)*I2/N;
dxdt(4) = k1*L1 - (mu + d1)*I1 - r2*I1;
dxdt(5) = k2*L2 - (mu + d2)*I2;

