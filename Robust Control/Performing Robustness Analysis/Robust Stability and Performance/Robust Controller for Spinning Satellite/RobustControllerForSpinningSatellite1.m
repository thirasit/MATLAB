%% Robust Controller for Spinning Satellite
% This example expands on the MIMO Stability Margins for Spinning Satellite example by designing a robust controller that overcomes the flaws of the "naive" design.

%%% Plant model
% The plant model is the same as described in MIMO Stability Margins for Spinning Satellite.
a = 10;
A = [0 a;-a 0];
B = eye(2);
C = [1 a;-a 1];
D = 0;
Gnom = ss(A,B,C,D);

%%% Nominal Mixed-Sensitivity Design
% Start with a basic mixed-sensitivity design using mixsyn.
% Pick the weights to achieve good performance while limiting bandwidth and control effort.
% (See Mixed-Sensitivity Loop Shaping for details about this technique and how to choose weighting functions.)
figure
wS = makeweight(1e3,1,1e-1);
wKS = makeweight(0.5,[500 1e2],1e4,0,2);
wT = makeweight(0.5,20,100);
bodemag(wS,wKS,wT), grid
legend('wS','wKS','wT')

% Compute the optimal MIMO controller K1 with mixsyn.
[K1,~,gam] = mixsyn(Gnom,wS,wKS,wT);
gam

% The optimal performance is about 0.7, indicating that mixsyn easily met the bounds on S,KS,T.
% Close the feedback loop and plot the step response.
figure
T = feedback(Gnom*K1,eye(2));
step(T,2), grid

% The nominal responses are fast with little overshoot.

%%% Disk Margins
% To gauge the robustness of this controller, check the disk margins at the plant inputs and the plant outputs.
figure
diskmarginplot(K1*Gnom,'b',Gnom*K1,'r--') 
grid
legend('At plant inputs','At plant outputs')

% Both are good with near 10 dB gain margin and 50 degrees phase margin.
% Also check the disk margins when the gain and phase are allowed to vary at both the inputs and outputs of the plant.
MMIO = diskmargin(Gnom,K1)

% The I/O margins are extremely small.
% This first design also lacks robustness.
% You can confirm the poor robustness by injecting the smallest destabilizing perturbations returned by diskmargin at the plant inputs and outputs.
% (See diskmargin for further details about the WorstPerturbation field of its output structures.)
figure
WP = MMIO.WorstPerturbation;
bode(WP.Input,WP.Output)
title('Smallest destabilizing perturbation')
legend('Input perturbation','Output perturbation')

figure
Tpert = feedback(WP.Output*Gnom*WP.Input*K1,eye(2));
step(Tpert,5)
grid

% The step response continues to oscillate after the initial transient indicating marginal instability.
% Verify that the perturbed closed-loop system Tpert has a pole on the imaginary axis at the critical frequency MMIO.Frequency.
[wn,zeta] = damp(Tpert); 
[~,idx] = min(zeta); 
[zeta(idx) wn(idx) MMIO.Frequency]

%%% Robust Design
% Create an uncertain plant model where the parameter a (spinning frequency) varies in the range [7 13].
a = ureal('a',10,'range',[7 13]);
A = [0 a;-a 0];
B = eye(2);
C = [1 a;-a 1];
D = 0;
Gunc = ss(A,B,C,D);

% You can use musyn to design a robust controller for this uncertain plant.
% To improve robustness, use the umargin element to model gain and phase uncertainty at both inputs and outputs, so that musyn enforces robustness for the modeled range of uncertainty.
% Suppose that you want at least 2 dB gain margin at each I/O (4 dB total for each channel).
% If your umargin elements model that full range of variation, musyn might not yield good results, because it attempts to enforce robust performance over the modeled uncertainty as well as robust stability.
% musyn most likely cannot maintained the desired performance for that much gain variation.
% Instead, scale back the target to 1 dB gain variation in each I/O.
GM = 1.1; % about 1 dB
u1 = umargin('u1',GM);
u2 = umargin('u2',GM);
y1 = umargin('y1',GM);
y2 = umargin('y2',GM);
InputMargins = append(u1,u2);
OutputMargins = append(y1,y2);
Gunc = OutputMargins*Gunc*InputMargins;

% Augment the plant with the mixed-sensitivity weights and use musyn to optimize robust performance for the modeled uncertainty, which includes both the parameter a and the gain and phase variations at plant inputs and outputs.
P = augw(Gunc,wS,wKS,wT);
[K2,gam] = musyn(P,2,2);

% The robust performance is close to 1, indicating that the controller is close to robustly meeting the mixed-sensitivity goals.
% Check the disk margins at the plant I/Os.
MMIO = diskmargin(Gnom,K2)

% The margins are now about 1.6 dB and 25 degrees, much better than before.
% Compare the step responses with each controller for 25 uncertainty samples.
figure
T1 = feedback(Gunc*K1,eye(2));
T2 = feedback(Gunc*K2,eye(2));
rng(0) % for reproducibility
T1s = usample(T1,25);
rng(0)
T2s = usample(T2,25);
opt = timeoptions; 
opt.YLim = {[-1 1.5]};
stepplot(T1s,T2s,4,opt)
grid
legend('Nominal design','Robust design','location','southeast')

% The second design is a clear improvement.
% Further compare the sensitivity and complementary sensitivity functions.
figure
sigma(eye(2)-T1s,eye(2)-T2s), grid
axis([1e-2 1e4 -80 20])
title('Sensitivity')
legend('Nominal design','Robust design','location','southeast')

figure
sigma(T1s,T2s), grid
axis([1e-2 1e4 -80 20])
title('Complementary Sensitivity')
legend('Nominal design','Robust design','location','southeast')

% This example has shown how to use the umargin uncertain element to improve stability margins as part of a robust controller synthesis.
