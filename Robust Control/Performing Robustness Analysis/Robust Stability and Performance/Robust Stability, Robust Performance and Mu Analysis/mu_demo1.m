%% Robust Stability, Robust Performance and Mu Analysis
% This example shows how to use Robust Control Toolbox™ to analyze and quantify the robustness of feedback control systems.
% It also provides insight into the connection with mu analysis and the mussv function.

%%% System Description
% Figure 1 shows the block diagram of a closed-loop system.
% The plant model P is uncertain and the plant output y must be regulated to remain small in the presence of disturbances d and measurement noise n.

figure
imshow("mu_demo_01.png")
axis off;

% Figure 1: Closed-loop system for robustness analysis

% Disturbance rejection and noise insensitivity are quantified by the performance objective
figure
imshow("Opera Snapshot_2023-08-04_085925_www.mathworks.com.png")
axis off;

% where W_d and W_n are weighting functions reflecting the frequency content of d and n.
% Here W_d is large at low frequencies and W_n is large at high frequencies.
figure
Wd = makeweight(100,.4,.15);
Wn = makeweight(0.5,20,100);
bodemag(Wd,'b--',Wn,'g--')
title('Performance Weighting Functions')
legend('Input disturbance','Measurement noise')

%%% Creating an Uncertain Plant Model
% The uncertain plant model P is a lightly-damped, second-order system with parametric uncertainty in the denominator coefficients and significant frequency-dependent unmodeled dynamics beyond 6 rad/s.
% The mathematical model looks like:

figure
imshow("Opera Snapshot_2023-08-04_090308_www.mathworks.com.png")
axis off;

% The parameter k is assumed to be about 40% uncertain, with a nominal value of 16.
% The frequency-dependent uncertainty at the plant input is assumed to be about 30% at low frequency, rising to 100% at 10 rad/s, and larger beyond that.
% Construct the uncertain plant model P by creating and combining the uncertain elements:
k = ureal('k',16,'Percentage',30);
delta = ultidyn('delta',[1 1],'SampleStateDim',4);
Wu = makeweight(0.3,10,20);
P = tf(16,[1 0.16 k]) * (1+Wu*delta);

%%% Designing a Controller
% We use the controller designed in the example "Improving Stability While Preserving Open-Loop Characteristics".
% The plant model used there happens to be the nominal value of the uncertain plant model created above.
% For completeness, we repeat the commands used to generate the controller.
K_PI = pid(1,0.8);
K_rolloff = tf(1,[1/20 1]);
Kprop = K_PI*K_rolloff;
[negK,~,Gamma] = ncfsyn(P.NominalValue,-Kprop);
K = -negK;

%%% Closing the Loop
% Use connect to build an uncertain model of the closed-loop system of Figure 1.
% Name the signals coming in and out of each block and let connect do the wiring:
P.u = 'uP';  P.y = 'yP';
K.u = 'uK';  K.y = 'yK';
S1 = sumblk('uP = yK + D');
S2 = sumblk('uK = -yP - N');
Wn.u = 'n'; Wn.y = 'N';
Wd.u = 'd'; Wd.y = 'D';
ClosedLoop = connect(P,K,S1,S2,Wn,Wd,{'d','n'},'yP');

% The variable ClosedLoop is an uncertain system with two inputs and one output.
% It depends on two uncertain elements: a real parameter k and an uncertain linear, time-invariant dynamic element delta.
ClosedLoop

%%% Robust Stability Analysis
% The classical margins from allmargin indicate good stability robustness to unstructured gain/phase variations within the loop.
allmargin(P.NominalValue*K)

% Does the closed-loop system remain stable for all values of k, delta in the ranges specified above? Answering this question requires a more sophisticated analysis using the robstab function.
[stabmarg,wcu] = robstab(ClosedLoop);
stabmarg

% The variable stabmarg gives upper and lower bounds on the robust stability margin, a measure of how much uncertainty on k, delta the feedback loop can tolerate before becoming unstable.
% For example, a margin of 0.8 indicates that as little as 80% of the specified uncertainty level can lead to instability.
% Here the margin is about 1.5, which means that the closed loop will remain stable for up to 150% of the specified uncertainty.

% The variable wcu contains the combination of k and delta closest to their nominal values that causes instability.
wcu

% We can substitute these values into ClosedLoop and verify that these values cause the closed-loop system to be unstable.
format short e
pole(usubs(ClosedLoop,wcu))

% Note that the natural frequency of the unstable closed-loop pole is given by stabmarg.CriticalFrequency:
stabmarg.CriticalFrequency

%%% Connection with Mu Analysis
% The structured singular value, or μ, is the mathematical tool used by robstab to compute the robust stability margin.
% If you are comfortable with structured singular value analysis, you can use the mussv function directly to compute mu as a function of frequency and reproduce the results above.
% The function mussv is the underlying engine for all robustness analysis commands.

% To use mussv, we first extract the (M,Delta) decomposition of the uncertain closed-loop model ClosedLoop, where Delta is a block-diagonal matrix of (normalized) uncertain elements.
% The 3rd output argument of lftdata, BlkStruct, describes the block-diagonal structure of Delta and can be used directly by mussv
[M,Delta,BlkStruct] = lftdata(ClosedLoop);

% For robust stability analysis, only the channels of M associated with the uncertainty channels are used.
% Based on the row/column size of Delta, select the proper columns and rows of M.
% Remember that the rows of Delta correspond to the columns of M, and vice versa.
% Consequently, the column dimension of Delta is used to specify the rows of M:
szDelta = size(Delta);
M11 = M(1:szDelta(2),1:szDelta(1));

% In its simplest form, mu-analysis is performed on a finite grid of frequencies.
% Pick a vector of logarithmically-spaced frequency points and evaluate the frequency response of M11 over this frequency grid.
omega = logspace(-1,2,50);
M11_g = frd(M11,omega);

% Compute mu(M11) at these frequencies and plot the resulting lower and upper bounds:
mubnds = mussv(M11_g,BlkStruct,'s');

figure
LinMagopt = bodeoptions;
LinMagopt.PhaseVisible = 'off'; LinMagopt.XLim = [1e-1 1e2]; LinMagopt.MagUnits = 'abs';
bodeplot(mubnds(1,1),mubnds(1,2),LinMagopt);
xlabel('Frequency (rad/sec)');
ylabel('Mu upper/lower bounds');
title('Mu plot of robust stability margins (inverted scale)');

% Figure 3: Mu plot of robust stability margins (inverted scale)

% The robust stability margin is the reciprocal of the structured singular value.
% Therefore upper bounds from mussv become lower bounds on the stability margin.
% Make these conversions and find the destabilizing frequency where the mu upper bound peaks (that is, where the stability margin is smallest):
[pkl,wPeakLow] = getPeakGain(mubnds(1,2));
[pku] = getPeakGain(mubnds(1,1));
SMfromMU.LowerBound = 1/pku;
SMfromMU.UpperBound = 1/pkl;
SMfromMU.CriticalFrequency = wPeakLow;

% Compare SMfromMU to the bounds stabmarg computed with robstab.
% The values are in rough agreement with robstab yielding slightly weaker margins.
% This is because robstab uses a more sophisticated approach than frequency gridding and can accurately compute the peak value of mu across frequency.
stabmarg

SMfromMU

%%% Robust Performance Analysis
% For the nominal values of the uncertain elements k and delta, the closed-loop gain is less than 1:
getPeakGain(ClosedLoop.NominalValue)

% This says that the controller K meets the disturbance rejection and noise insensitivity goals.
% But is this nominal performance maintained in the face of the modeled uncertainty?
% This question is best answered with robgain.
opt = robOptions('Display','on');
[perfmarg,wcu] = robgain(ClosedLoop,1,opt);

% The answer is negative: robgain found a perturbation amounting to only 40% of the specified uncertainty that drives the closed-loop gain to 1.
getPeakGain(usubs(ClosedLoop,wcu),1e-6)

% This suggests that the closed-loop gain will exceed 1 for 100% of the specified uncertainty.
% This is confirmed by computing the worst-case gain:
wcg = wcgain(ClosedLoop)

% The worst-case gain is about 1.6.
% This analysis shows that while the controller K meets the disturbance rejection and noise insensitivity goals for the nominal plant, it is unable to maintain this level of performance for the specified level of plant uncertainty.
