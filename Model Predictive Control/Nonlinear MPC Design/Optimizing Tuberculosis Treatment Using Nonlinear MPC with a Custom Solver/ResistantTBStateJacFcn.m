function [A,B] = ResistantTBStateJacFcn(x,u)
% Jacobian for evolution of resistant TB in a population of N individuals
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
%   u(2):  "case holding - Effort to maintain effective treatment.
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

% Linearized model coefficient matrices. Note that L1 = N - sum(x), so
% this effect must be included.

A = zeros(5,5);
% f(1) = mu*N - (beta1*I1 + betastar*I2)*S/N - mu*S;
A(1,1) = - mu -(beta1*I1 + betastar*I2)/N;
A(1,4) = -beta1*S/N;
A(1,5) = -betastar*S/N;
% f(2) = Finding*r1*L1 - mu*T + (1 - (1 - Holding)*(p + q))*r2*I1 - (beta2*T*I1 + betastar*T*I2)/N;
df2dL1  = -Finding*r1;
A(2,2) = -mu - beta2*I1/N - betastar*I2/N;
A(2,4) = (1 - (1 - Holding)*(p + q))*r2 - beta2*T/N;
A(2,5) = -betastar*T/N;
A(2,:) = A(2,:) + df2dL1;
% f(3) = (1-Holding)*q*r2*I1 - (mu + k2)*L2 + betastar*(S + L1 + T)*I2/N;
A(3,1) = betastar*I2/N;
A(3,2) = betastar*I2/N;
A(3,3) = -(mu + k2);
A(3,4) = (1-Holding)*q*r2;
A(3,5) = betastar*(S + L1 + T)/N;
df3dL1 = -betastar*I2/N;
A(3,:) = A(3,:) + df3dL1;
% f(4) = k1*L1 - (mu + d1)*I1 - r2*I1;
A(4,4) = -(mu + d1) - r2;
df4dL1 = -k1;
A(4,:) = A(4,:) + df4dL1;
% f(5) = k2*L2 - (mu + d2)*I2;
A(5,3) = k2;
A(5,5) = -(mu + d2);

B = zeros(5,2);
B(2,1) = r1*L1;
B(2,2) = (p + q)*r2*I1;
B(3,2) = -q*r2*I1;
    