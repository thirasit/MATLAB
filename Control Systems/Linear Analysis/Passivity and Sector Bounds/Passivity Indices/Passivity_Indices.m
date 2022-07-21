%% Passivity Indices

% This example shows how to compute various measures of passivity for linear time-invariant systems.

%%% Passive Systems

% A linear system G(s) is passive when all I/O trajectories (u(t),y(t)) satisfy

figure
imshow("Opera Snapshot_2022-07-21_121439_www.mathworks.com.png")

% where y^T(t) denotes the transpose of y(t).

figure
imshow("PassivityIndicesExample_01.png")

% To measure "how passive" a system is, we use passivity indices.

% - The input passivity index is defined as the largest ν such that

figure
imshow("Opera Snapshot_2022-07-21_121817_www.mathworks.com.png")

% The system G is "input strictly passive" (ISP) when ν>0. 
% ν is also called the "input feedforward passivity" (IFP) index and corresponds to 
% the minimum feedforward action needed to make the system passive.

% - The output passivity index is defined as the largest ρ such that

figure
imshow("Opera Snapshot_2022-07-21_122031_www.mathworks.com.png")

% The system G is "output strictly passive" (OSP) when ρ>0. 
% ρ is also called the "output feedback passivity" (OFP) index and corresponds to 
% the minimum feedback action needed to make the system passive.

% - The I/O passivity index is defined as the largest τ such that

figure
imshow("Opera Snapshot_2022-07-21_122215_www.mathworks.com.png")

% The system is "very strictly passive" (VSP) if τ>0.

%%% Circuit Example

% Consider the following example. 
% We take the current I as the input and the voltage V as the output. 
% Based on Kirchhoff's current and voltage law, we obtain the transfer function for G(s),

figure
imshow("Opera Snapshot_2022-07-21_122355_www.mathworks.com.png")

figure
imshow("PassivityIndicesExample_02.png")

% Let R=2, L=1 and C=0.1.

R = 2; L = 1; C = 0.1; 
s = tf('s');
G = (L*s+R)*(R*s+1/C)/(L*s^2 + 2*R*s+1/C);

% Use isPassive to check whether G(s) is passive.

PF = isPassive(G)

% Since PF = true, G(s) is passive. Use getPassiveIndex to compute the passivity indices of G(s).

% Input passivity index
nu = getPassiveIndex(G,'in')

% Output passivity index
rho = getPassiveIndex(G,'out')

% I/O passivity index
tau = getPassiveIndex(G,'io')

% Since τ>0, the system G(s) is very strictly passive.

%%% Frequency-Domain Characterization

% A linear system is passive if and only if it is "positive real":

figure
imshow("Opera Snapshot_2022-07-21_122755_www.mathworks.com.png")

% The smallest eigenvalue of the left-hand-side is related to the input passivity index ν:

figure
imshow("Opera Snapshot_2022-07-21_122847_www.mathworks.com.png")

% where λ_min denotes the smallest eigenvalue. 
% Similarly, when G(s) is minimum-phase, the output passivity index is given by:

figure
imshow("Opera Snapshot_2022-07-21_123004_www.mathworks.com.png")

% Verify this for the circuit example. Plot the Nyquist plot of the circuit transfer function.

figure
nyquist(G)

% The entire Nyquist plot lies in the right-half plane so G(s) is positive real. 
% The leftmost point on the Nyquist curve is (x,y)=(2,0) so the input passivity index is ν=2, 
% the same value we obtained earlier. Similarly, the leftmost point on the Nyquist curve for G^−1(s) 
% gives the output passivity index value ρ=0.286.

%%% Relative Passivity Index

% It can be shown that the "positive real" condition

figure
imshow("Opera Snapshot_2022-07-21_123245_www.mathworks.com.png")

% is equivalent to the small gain condition

figure
imshow("Opera Snapshot_2022-07-21_123347_www.mathworks.com.png")

% The relative passivity index (R-index) is the peak gain over frequency of (I−G)(I+G)^−1
% when I+G is minimum phase, and +∞ otherwise:

figure
imshow("Opera Snapshot_2022-07-21_123458_www.mathworks.com.png")

% In the time domain, the R-index is the smallest r>0 such that

figure
imshow("Opera Snapshot_2022-07-21_123624_www.mathworks.com.png")

% The system G(s) is passive if and only if R<1, and the smaller R is, the more passive the system is. 
% Use getPassiveIndex to compute the R-index for the circuit example.

R = getPassiveIndex(G)

% The resulting R value indicates that the circuit is a very passive system.

%% References
% [1] Xia, M., P. Gahinet, N. Abroug, C. Buhr, and E. Laroche. "Sector Bounds in Stability Analysis and Control Design." International Journal of Robust and Nonlinear Control 30, no. 18 (December 2020): 7857–82. https://doi.org/10.1002/rnc.5236.
