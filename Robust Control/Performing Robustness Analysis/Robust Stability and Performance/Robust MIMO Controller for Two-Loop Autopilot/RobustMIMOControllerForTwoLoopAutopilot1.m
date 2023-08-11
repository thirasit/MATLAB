%% Robust MIMO Controller for Two-Loop Autopilot
% This example shows how to design a robust controller for a two-loop autopilot that controls the pitch rate and vertical acceleration of an airframe.
% The controller is robust against gain and phase variations in the multichannel feedback loop.

%%% Linearized Airframe Model
% The airframe dynamics and the autopilot are modeled in Simulink.
% See Tuning of a Two-Loop Autopilot for more information about this model and for additional design and tuning options.
open_system('rct_airframe2')

figure
imshow("RobustMIMOControllerForTwoLoopAutopilotExample_01.png")
axis off;

% As in the example Tuning of a Two-Loop Autopilot, trim the airframe for $\alpha=0$ and $V = 984 m/s$.
% The trim condition corresponds to zero normal acceleration and pitching moment ($w$ and $q$ steady).
% Use findop to compute the corresponding operating condition.
% Then, linearize the airframe model at this trim condition.
opspec = operspec('rct_airframe2');

% Specify trim condition
% Xe,Ze: known, not steady
opspec.States(1).Known = [1;1];
opspec.States(1).SteadyState = [0;0];
% u,w: known, w steady
opspec.States(3).Known = [1 1];
opspec.States(3).SteadyState = [0 1];
% theta: known, not steady
opspec.States(2).Known = 1;
opspec.States(2).SteadyState = 0;
% q: unknown, steady
opspec.States(4).Known = 0;
opspec.States(4).SteadyState = 1;
% controller states unknown, not steady
opspec.States(5).SteadyState = [0;0];

op = findop('rct_airframe2',opspec);
G = linearize('rct_airframe2','rct_airframe2/Airframe Model',op);
G.InputName = 'delta';
G.OutputName = {'az','q'};

%%% Nominal Controller Design
% Design an H-infinity controller that responds to a step change in vertical acceleration under 1 second.
% Use a mixed-sensitivity formulation with a lowpass weight wS that penalizes low-frequency tracking error and a highpass weight wT that enforces adequate roll-off.
% Build an augmented plant with azref,delta as inputs and the filtered wS*e,wT*az,e,q as outputs.
% (For information about the mixed-sensitivity formulation, see Mixed-Sensitivity Loop Shaping.)
sb = sumblk('e = azref-az');
wS = makeweight(1e2,5,0.1);
wS.u = 'e';
wS.y = 'we';
wT = makeweight(0.1,50,1e2);
wT.u = 'az';
wT.y = 'waz';

Paug = connect(G,wS,wT,sb,{'azref','delta'},{'we','waz','e','q'});

% Compute the optimal H-infinity controller using hinfsyn.
% In this configuration there are two measurements e,q and one control delta.
[Knom,~,gam] = hinfsyn(Paug,2,1);
gam

% Verify the open-loop gain against wS,wT.
f = figure();
sigma(Knom*G,wS,'r--',1/wT,'g--'), grid
legend('open-loop gain','> wS at low freq','< 1/wT at high freq')

% Plot the closed-loop response.
figure
CL = feedback(G*Knom,diag([1 -1]));
step(CL(:,1)), grid

%%% Robustness Analysis
% Compute the disk margins at the plant input and outputs.
% That the az loop uses negative feedback while the q loop uses positive feedback, so change the sign of the loop gain of the q loop before using diskmargin.
loopsgn = diag([1 -1]);

% Examine the margins at the plant input.
DM = diskmargin(Knom*loopsgn*G)

% For the margins at plant outputs, use the multiloop margin to account for simultaneous, independent variations in both output channels.
[~,MM] = diskmargin(loopsgn*G*Knom)

% Finally, compute the margins against simultaneous variations at the plant input and outputs.
MMIO = diskmargin(loopsgn*G,Knom)

% The disk-based gain and phase margins exceed 2 (6dB) and 35 degrees at the plant input and the plant outputs.
% Moreover, MMIO indicates that this feedback loop can withstand gain variations by a factor 1.45 or phase variations of 21 degrees affecting all plant inputs and outputs at once.

% Next, investigate the impact of gain and phase uncertainty on performance.
% Use the umargin control design block to model a gain change factor of 1.4 (3dB) and phase change of 20 degrees in each feedback channel.
% Use getDGM to fit an uncertainty disk to these amounts of gain and phase change.
GM = 1.4;
PM = 20;
DGM = getDGM(GM,PM,'balanced');
ue = umargin('e',DGM);
uq = umargin('q',DGM);
Gunc = blkdiag(ue,uq)*G;
Gunc.OutputName = {'az','q'};

% Rebuild the closed-loop model and sample the gain and phase uncertainty to gauge the impact on the step response.
figure
CLunc = feedback(Gunc*Knom,loopsgn);
step(CLunc(:,1),3)
grid

% The plot shows significant variability in performance, with large overshoot and steady-state error for some combinations of gain and phase variations.

%%% Robust Controller Synthesis
% Redo the controller synthesis to account for gain and phase variations using musyn.
% This synthesis optimizes performance uniformly for the specified range of gain and phase uncertainty.
Punc = connect(Gunc,wS,wT,sb,{'azref','delta'},{'we','waz','e','q'});
[Kr,gam] = musyn(Punc,2,1);
gam

% Compare the sampled step responses for the nominal and robust controllers.
% The robust design reduces both overshoot and steady-state errors and gives more consistent performance across the modeled range of gain and phase uncertainty.
figure
CLr = feedback(Gunc*Kr,loopsgn);
rng(0) % for reproducibility
step(CLunc(:,1),3)
hold
rng(0)
step(CLr(:,1),3)
grid

% The robust controller achieves this performance by increasing the (nominal) disk margins at the plant output and, to a lesser extent, the I/O disk margin.
% For instance, compare the disk-based margins at the plant outputs for the nominal and robust designs.
% Use diskmarginplot to see the variations of the margins with frequency.
figure
Lnom = loopsgn*G*Knom;
Lrob = loopsgn*G*Kr;
clf
diskmarginplot(Lnom,Lrob)
title('Disk margins at plant outputs')
grid
legend('Nominal','Robust')

% Examine the margins against variations simultaneous variations at the plant inputs and outputs with the robust controller.
MMIO = diskmargin(loopsgn*G,Kr)

% Recall that with the nominal controller, the feedback loop could withstand gain variations of a factor of 1.45 or phase variations of 21 degrees affecting all plant inputs and outputs at once.
% With the robust controller, those margins increase to about 1.54 and 24 degrees.

% View the range of simultaneous gain and phase variations that the robust design can sustain at all plant inputs and outputs.
diskmarginplot(MMIO.GainMargin)

%%% Nonlinear Simulation of Worst-Case Scenario
% diskmargin returns the smallest change in gain and phase that destabilizes the feedback loop.
% It can be insightful to inject this perturbation in the nonlinear simulation to further analyze the implications for the real system.
% For example, compute the destabilizing perturbation at the plant outputs for the nominal controller.
figure
[~,MM] = diskmargin(Lnom);
WP = MM.WorstPerturbation;
bode(WP)
title('Smallest destabilizing perturbation')

% The worst perturbation is a diagonal, dynamic perturbation that multiplies the open-loop response at the plant outputs.
% With this perturbation, the closed-loop system becomes unstable with an undamped pole at the frequency w0 = MM.Frequency.
damp(feedback(WP*G*Knom,loopsgn))

w0 = MM.Frequency

% Note that the gain and phase variations induced by this perturbation lie on the boundary of the range of safe gain/phase variations computed by diskmargin.
% To confirm this result, compute the frequency response of the worst perturbation at the frequency w0, convert it to a gain and phase variation, and visualize it along with the range of safe gain and phase variations represented by the multiloop disk margin.
DELTA = freqresp(WP,w0);

diskmarginplot(MM.GainMargin)
title('Range of stable gain and phase variations')
hold on
plot(20*log10(abs(DELTA(1,1))),abs( angle(DELTA(1,1))*180/pi),'ro')
plot(20*log10(abs(DELTA(2,2))),abs( angle(DELTA(2,2))*180/pi),'ro')

% To simulate the effect of this worst perturbation on the full nonlinear model in Simulink, insert it as a block before the controller block, as done in the modified model rct_airframeWP.
close(f)
open_system('rct_airframeWP')

figure
imshow("RobustMIMOControllerForTwoLoopAutopilotExample_10.png")
axis off;

% Here the MIMO Controller block is set to the nominal controller Knom.
% To simulate the nonlinear response with this controller, compute the trim deflection and q initial value from the operating condition op.
delta_trim = op.Inputs.u + [1.5 0]*op.States(5).x;
q_ini = op.States(4).x;

% By commenting the WorstPerturbation block in and out, you can simulate the response with or without this perturbation.
% The results are shown below and confirm the destabilizing effect of the gain and phase variation computed by diskmargin.

figure
imshow("xxairframesim_nopert.png")
axis off;

% Figure 1: Nominal response.

figure
imshow("xxairframesim_pert.png")
axis off;

% Figure 2: Response with destabilizing gain/phase perturbation.
