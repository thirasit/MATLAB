%% Fixed-Structure H-infinity Synthesis with hinfstruct
% This example uses the hinfstruct command to tune a fixed-structure controller subject to H_∞ constraints.

%%% Introduction
% The hinfstruct command extends classical H_∞ synthesis (see hinfsyn) to fixed-structure control systems.
% This command is meant for users already comfortable with the hinfsyn workflow.
% If you are unfamiliar with H_∞ synthesis or find augmented plants and weighting functions intimidating, use systune and looptune instead.
% See Tune Control Systems Using systune for the systune counterpart of this example.

%%% Plant Model
% This example uses a 9th-order model of the head-disk assembly (HDA) in a hard-disk drive.
% This model captures the first few flexible modes in the HDA.
load hinfstruct_demo G
figure
bode(G), grid

% We use the feedback loop shown below to position the head on the correct track.
% This control structure consists of a PI controller and a low-pass filter in the return path.
% The head position y should track a step change r with a response time of about one millisecond, little or no overshoot, and no steady-state error.

figure
imshow("hinfstruct_demo_02.png")
axis off;

% Figure 1: Control Structure

%%% Tunable Elements
% There are two tunable elements in the control structure of Figure 1: the PI controller C(s) and the low-pass filter

figure
imshow("Opera Snapshot_2023-09-11_055925_www.mathworks.com.png")
axis off;

% Use the tunablePID class to parameterize the PI block and specify the filter F(s) as a transfer function depending on a tunable real parameter a.
C0 = tunablePID('C','pi');  % tunable PI

a = realp('a',1);    % filter coefficient
F0 = tf(a,[1 a]);    % filter parameterized by a

%%% Loop Shaping Design
% Loop shaping is a frequency-domain technique for enforcing requirements on response speed, control bandwidth, roll-off, and steady state error.
% The idea is to specify a target gain profile or "loop shape" for the open-loop response L(s)=F(s)G(s)C(s).
% A reasonable loop shape for this application should have integral action and a crossover frequency of about 1000 rad/s (the reciprocal of the desired response time of 0.001 seconds).
% This suggests the following loop shape:
figure
wc = 1000;  % target crossover
s = tf('s');
LS = (1+0.001*s/wc)/(0.001+s/wc);
bodemag(LS,{1e1,1e5}), grid, title('Target loop shape')

% Note that we chose a bi-proper, bi-stable realization to avoid technical difficulties with marginally stable poles and improper inverses.
% In order to tune C(s) and F(s) with hinfstruct, we must turn this target loop shape into constraints on the closed-loop gains.
% A systematic way to go about this is to instrument the feedback loop as follows:
% - Add a measurement noise signal n
% - Use the target loop shape LS and its reciprocal to filter the error signal e and the white noise source nw.

figure
imshow("hinfstruct_demo_04.png")
axis off;

% Figure 2: Closed-Loop Formulation

figure
imshow("Opera Snapshot_2023-09-11_060225_www.mathworks.com.png")
axis off;

%%% Specifying the Control Structure in MATLAB
% In MATLAB, you can use the connect command to model T(s) by connecting the fixed and tunable components according to the block diagram of Figure 2:

% Label the block I/Os
Wn = 1/LS;  Wn.u = 'nw';  Wn.y = 'n';
We = LS;    We.u = 'e';   We.y = 'ew';
C0.u = 'e';   C0.y = 'u';
F0.u = 'yn';  F0.y = 'yf';

% Specify summing junctions
Sum1 = sumblk('e = r - yf');
Sum2 = sumblk('yn = y + n');

% Connect the blocks together
T0 = connect(G,Wn,We,C0,F0,Sum1,Sum2,{'r','nw'},{'y','ew'});

% These commands construct a generalized state-space model T0 of T(s).
% This model depends on the tunable blocks C and a:
T0.Blocks

% Note that T0 captures the following "Standard Form" of the block diagram of Figure 2 where the tunable components C,F are separated from the fixed dynamics.

figure
imshow("hinfstruct_demo_05.png")
axis off;

% Figure 3: Standard Form for Disk-Drive Loop Shaping

%%% Tuning the Controller Gains
% We are now ready to use hinfstruct to tune the PI controller C and filter F for the control architecture of Figure 1.
% To mitigate the risk of local minima, run three optimizations, two of which are started from randomized initial values for C0 and F0.
rng('default')
opt = hinfstructOptions('Display','final','RandomStart',5);
T = hinfstruct(T0,opt);

figure
imshow("Opera Snapshot_2023-09-11_060452_www.mathworks.com.png")
axis off;

showTunable(T)

% Use getBlockValue to get the tuned value of C(s) and use getValue to evaluate the filter F(s) for the tuned value of a:
C = getBlockValue(T,'C');
F = getValue(F0,T.Blocks);  % propagate tuned parameters from T to F

tf(F)

% To validate the design, plot the open-loop response L=F*G*C and compare with the target loop shape LS:
figure
bode(LS,'r--',G*C*F,'b',{1e1,1e6}), grid, 
title('Open-loop response'), legend('Target','Actual')

% The 0dB crossover frequency and overall loop shape are as expected.
% The stability margins can be read off the plot by right-clicking and selecting the Characteristics menu.
% This design has 24dB gain margin and 81 degrees phase margin.
% Plot the closed-loop step response from reference r to position y:
figure
step(feedback(G*C,F)), grid, title('Closed-loop response')

% While the response has no overshoot, there is some residual wobble due to the first resonant peaks in G.
% You might consider adding a notch filter in the forward path to remove the influence of these modes.

%%% Tuning the Controller Gains from Simulink
% Suppose you used this Simulink model to represent the control structure.
% If you have Simulink Control Design installed, you can tune the controller gains from this Simulink model as follows.
% First mark the signals r,e,y,n as Linear Analysis points in the Simulink model.

figure
imshow("hinfstruct_demo_08.png")
axis off;

% Then create an instance of the slTuner interface and mark the Simulink blocks C and F as tunable:
ST0 = slTuner('rct_diskdrive',{'C','F'});

% Since the filter F(s) has a special structure, explicitly specify how to parameterize the F block:
a = realp('a',1);    % filter coefficient
setBlockParam(ST0,'F',tf(a,[1 a]));

% Finally, use getIOTransfer to derive a tunable model of the closed-loop transfer function T(s) (see Figure 2)
% Compute tunable model of closed-loop transfer (r,n) -> (y,e)
T0 = getIOTransfer(ST0,{'r','n'},{'y','e'});

% Add weighting functions in n and e channels
T0 = blkdiag(1,LS) * T0 * blkdiag(1,1/LS);

% You are now ready to tune the controller gains with hinfstruct:
rng(0)
opt = hinfstructOptions('Display','final','RandomStart',5);
T = hinfstruct(T0,opt);

% Verify that you obtain the same tuned values as with the MATLAB approach:
showTunable(T)
