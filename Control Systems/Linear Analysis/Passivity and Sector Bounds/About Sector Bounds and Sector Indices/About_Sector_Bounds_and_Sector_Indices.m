%% About Sector Bounds and Sector Indices

%%% Conic Sectors

% In its simplest form, a conic sector is the 2-D region delimited by two lines, y=au and y=bu.

figure
imshow("SectorBoundsAndSectorIndicesExample_01.png")

% The shaded region is characterized by the inequality (y−au)(y−bu)<0. 
% More generally, any such sector can be parameterized as:

figure
imshow("Opera Snapshot_2022-07-22_102709_www.mathworks.com.png")

% where Q is a 2x2 symmetric indefinite matrix (Q has one positive and one negative eigenvalue). 
% We call Q the sector matrix. 
% This concept generalizes to higher dimensions. In an N-dimensional space, a conic sector is a set:

figure
imshow("Opera Snapshot_2022-07-22_102835_www.mathworks.com.png")

% where Q is again a symmetric indefinite matrix.

%%% Sector Bounds

% Sector bounds are constraints on the behavior of a system. 
% Gain constraints and passivity constraints are special cases of sector bounds. 
% If for all nonzero input trajectories u(t), the output trajectory z(t)=(Hu)(t) of a linear system H(s) satisfies:

figure
imshow("Opera Snapshot_2022-07-22_103011_www.mathworks.com.png")

% then the output trajectories of H lie in the conic sector with matrix Q. 
% Selecting different Q matrices imposes different conditions on the system's response. 
% For example, consider trajectories y(t)=(Gu)(t) and the following values:

figure
imshow("Opera Snapshot_2022-07-22_103110_www.mathworks.com.png")

% These values correspond to the sector bound:

figure
imshow("Opera Snapshot_2022-07-22_103206_www.mathworks.com.png")

% This sector bound is equivalent to the passivity condition for G(s):

figure
imshow("Opera Snapshot_2022-07-22_103315_www.mathworks.com.png")

% In other words, passivity is a particular sector bound on the system defined by:

figure
imshow("Opera Snapshot_2022-07-22_103405_www.mathworks.com.png")

%%% Frequency-Domain Condition

% Because the time-domain condition must hold for all T>0, 
% deriving an equivalent frequency-domain bound takes a little care and is not always possible. 
% Let the following:

figure
imshow("Opera Snapshot_2022-07-22_103525_www.mathworks.com.png")

% be (any) decomposition of the indefinite matrix Q into its positive and negative parts. 
% When (W^T)_2 H(s) is square and minimum phase (has no unstable zeros), the time-domain condition:

figure
imshow("Opera Snapshot_2022-07-22_103721_www.mathworks.com.png")

% is equivalent to the frequency-domain condition:

figure
imshow("Opera Snapshot_2022-07-22_103816_www.mathworks.com.png")

% It is therefore enough to check the sector inequality for real frequencies. 
% Using the decomposition of Q, this is also equivalent to:

figure
imshow("Opera Snapshot_2022-07-22_103904_www.mathworks.com.png")

% Note that (W^T)_2 H is square when Q has as many negative eigenvalues as input channels in H(s). 
% If this condition is not met, it is no longer enough (in general) to just look at real frequencies. 
% Note also that if (W^T)_2 H(s) is square, then it must be minimum phase for the sector bound to hold.

% This frequency-domain characterization is the basis for sectorplot. 
% Specifically, sectorplot plots the singular values of

figure
imshow("Opera Snapshot_2022-07-22_104155_www.mathworks.com.png")

% as a function of frequency. 
% The sector bound is satisfied if and only if the largest singular value stays below 1. 
% Moreover, the plot contains useful information about the frequency bands 
% where the sector bound is satisfied or violated, and the degree to which it is satisfied or violated.

% For instance, examine the sector plot of a 2-output, 2-input system for a particular sector.

figure
rng(4,'twister');
H = rss(3,4,2); 
Q = [-5.12   2.16  -2.04   2.17
      2.16  -1.22  -0.28  -1.11
     -2.04  -0.28  -3.35   0.00
      2.17  -1.11   0.00   0.18];
sectorplot(H,Q)

% The plot shows that the largest singular value of

figure
imshow("Opera Snapshot_2022-07-22_104155_www.mathworks.com.png")

% exceeds 1 below about 0.5 rad/s and in a narrow band around 3 rad/s. 
% Therefore, H does not satisfy the sector bound represented by Q.

%%% Relative Sector Index

% We can extend the notion of relative passivity index to arbitrary sectors. 
% Let H(s) be an LTI system, and let:

figure
imshow("Opera Snapshot_2022-07-22_104624_www.mathworks.com.png")

% be an orthogonal decomposition of Q into its positive and negative parts, 
% as is readily obtained from the Schur decomposition of Q. 
% The relative sector index R, or R-index, 
% is defined as the smallest r>0 such that for all output trajectories z(t)=(Hu)(t):

figure
imshow("Opera Snapshot_2022-07-22_104735_www.mathworks.com.png")

% Because increasing r makes

figure
imshow("Opera Snapshot_2022-07-22_104846_www.mathworks.com.png")

% more negative, the inequality is usually satisfied for r large enough. 
% However, there are cases when it can never be satisfied, in which case the R-index is R=+∞. 
% Clearly, the original sector bound is satisfied if and only of R≤1.

% To understand the geometrical interpretation of the R-index, consider the family of cones with matrix

figure
imshow("Opera Snapshot_2022-07-22_105015_www.mathworks.com.png")

% In 2D, the cone slant angle θ is related to r by

figure
imshow("Opera Snapshot_2022-07-22_105118_www.mathworks.com.png")

% (see diagram below). 
% More generally, tan(θ) is proportional to R. 
% Thus, given a conic sector with matrix Q, an R-index value R<1 means that 
% we can reduce tan(θ) (narrow the cone) by a factor R before some output trajectory of H leaves the conic sector. 
% Similarly, a value R>1 means that we must increase tan(θ) (widen the cone) by a factor R to include all output trajectories of H. 
% This clearly makes the R-index a relative measure of how well the response of H fits in a particular conic sector.

figure
imshow("SectorBoundsAndSectorIndicesExample_03.png")

% In the diagram,

figure
imshow("Opera Snapshot_2022-07-22_105422_www.mathworks.com.png")

% and

figure
imshow("Opera Snapshot_2022-07-22_105514_www.mathworks.com.png")

% When (W^T)_2 H(s) is square and minimum phase, the R-index can also be characterized in the frequency domain as the smallest r>0 such that:

figure
imshow("Opera Snapshot_2022-07-22_105627_www.mathworks.com.png")

% Using elementary algebra, this leads to:

figure
imshow("Opera Snapshot_2022-07-22_105723_www.mathworks.com.png")

% In other words, the R-index is the peak gain of the (stable) transfer function

figure
imshow("Opera Snapshot_2022-07-22_105832_www.mathworks.com.png")

% and the singular values of Φ(jw) can be seen as the "principal" R-indices at each frequency. 
% This also explains why plotting the R-index vs. frequency looks like a singular value plot (see sectorplot).
% There is a complete analogy between relative sector index and system gain. 
% Note, however, that this analogy only holds when (W^T)_2 H(s) is square and minimum phase.

%%% Directional Sector Index

% Similarly, we can extend the notion of directional passivity index to arbitrary sectors. 
% Given a conic sector with matrix Q, and a direction δQ, the directional sector index is the largest τ such that for all output trajectories z(t)=(Hu)(t):

figure
imshow("Opera Snapshot_2022-07-24_182014_www.mathworks.com.png")

% The directional passivity index for a system G(s) corresponds to:

figure
imshow("Opera Snapshot_2022-07-24_182121_www.mathworks.com.png")

% The directional sector index measures by how much we need to deform the sector in the direction δQ to make it fit tightly around the output trajectories of H. 
% The sector bound is satisfied if and only if the directional index is positive.

%%% Common Sectors

% There are many ways to specify sector bounds. 
% Next we review commonly encountered expressions and give the corresponding system H 
% and sector matrix Q for the standard form used by getSectorIndex and sectorplot:

figure
imshow("Opera Snapshot_2022-07-24_182510_www.mathworks.com.png")

% For simplicity, these descriptions use the notation:

figure
imshow("Opera Snapshot_2022-07-24_182614_www.mathworks.com.png")

% and omit the ∀T>0 requirement.

% Passivity
% Passivity is a sector bound with:
figure
imshow("Opera Snapshot_2022-07-24_182754_www.mathworks.com.png")

% Gain constraint
% The gain constraint ‖G‖_∞ <γ is a sector bound with:
figure
imshow("Opera Snapshot_2022-07-24_182937_www.mathworks.com.png")

% Ratio of distances
% Consider the "interior" constraint,
figure
imshow("Opera Snapshot_2022-07-24_183108_www.mathworks.com.png")

% where c,r are scalars and y(t)=(Gu)(t). This is a sector bound with:
figure
imshow("Opera Snapshot_2022-07-24_183148_www.mathworks.com.png")

% The underlying conic sector is symmetric with respect to y=cu. Similarly, the "exterior" constraint,
figure
imshow("Opera Snapshot_2022-07-24_183236_www.mathworks.com.png")

% is a sector bound with:
figure
imshow("Opera Snapshot_2022-07-24_183353_www.mathworks.com.png")

% Double inequality
% When dealing with static nonlinearities, it is common to consider conic sectors of the form
figure
imshow("Opera Snapshot_2022-07-24_183721_www.mathworks.com.png")

% where y=ϕ(u) is the nonlinearity output. While this relationship is not a sector bound per se, it clearly implies:
figure
imshow("Opera Snapshot_2022-07-24_183758_www.mathworks.com.png")

% along all I/O trajectories and for all T>0. This condition in turn is equivalent to a sector bound with:
figure
imshow("Opera Snapshot_2022-07-24_184059_www.mathworks.com.png")

% Product form
% Generalized sector bounds of the form:
figure
imshow("Opera Snapshot_2022-07-24_184213_www.mathworks.com.png")

% correspond to:
figure
imshow("Opera Snapshot_2022-07-24_184300_www.mathworks.com.png")

% As before, the static sector bound:
figure
imshow("Opera Snapshot_2022-07-24_184350_www.mathworks.com.png")

% implies the integral sector bound above.

% QSR dissipative
% A system y=Gu is QSR-dissipative if it satisfies:
figure
imshow("Opera Snapshot_2022-07-24_184506_www.mathworks.com.png")

% This is a sector bound with:
figure
imshow("Opera Snapshot_2022-07-24_184719_www.mathworks.com.png")

%% References
% [1] Xia, M., P. Gahinet, N. Abroug, C. Buhr, and E. Laroche. “Sector Bounds in Stability Analysis and Control Design.” International Journal of Robust and Nonlinear Control 30, no. 18 (December 2020): 7857–82. https://doi.org/10.1002/rnc.5236.
