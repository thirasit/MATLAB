%% Fixed-Structure Autopilot for a Passenger Jet

% This example shows how to use slTuner and systune to tune the standard configuration of a longitudinal autopilot. 
% We thank Professor D. Alazard from Institut Superieur de l'Aeronautique et de l'Espace for providing the aircraft model and Professor Pierre Apkarian from ONERA for developing the example.

%%% Aircraft Model and Autopilot Configuration
% The longitudinal autopilot for a supersonic passenger jet flying at Mach 0.7 and 5000 ft is depicted in Figure 1. 
% The autopilot main purpose is to follow vertical acceleration commands $N_{zc}$ issued by the pilot. 
% The feedback structure consists of an inner loop controlling the pitch rate $q$ and an outer loop controlling the vertical acceleration $N_z$. 
% The autopilot also includes a feedforward component and a reference model $G_{ref}(s)$ that specifies the desired response to a step command $N_{zc}$. 
% Finally, the second-order roll-off filter

figure
imshow("concorde_demo_eq12997878801868473776.png")

% is used to attenuate noise and limit the control bandwidth as a safeguard against unmodeled dynamics. 
% The tunable components are highlighted in orange.

figure
imshow("xxconcordedemo1.png")

% Figure 1: Longitudinal Autopilot Configuration.

% The aircraft model $G(s)$ is a 5-state model, the state variables being the aerodynamic speed $V$ (m/s), the climb angle $\gamma$ (rad), the angle of attack $\alpha$ (rad), the pitch rate $q$ (rad/s), and the altitude $H$ (m). 
% The elevator deflection $\delta_m$ (rad) is used to control the vertical load factor $N_z$. 
% The open-loop dynamics include the $\alpha$ oscillation with frequency and damping ratio $\omega_n$ = 1.7 (rad/s) and $\zeta$ = 0.33, the phugoid mode $\omega_n$ = 0.64 (rad/s) and $\zeta$ = 0.06, and the slow altitude mode $\lambda$ = -0.0026.

figure
load ConcordeData G
bode(G,{1e-3,1e2}), grid
title('Aircraft Model')

% Note the zero at the origin in $G(s)$. 
% Because of this zero, we cannot achieve zero steady-state error and must instead focus on the transient response to acceleration commands. 
% Note that acceleration commands are transient in nature so steady-state behavior is not a concern. 
% This zero at the origin also precludes pure integral action so we use a pseudo-integrator $1/(s+\epsilon)$ with $\epsilon$ = 0.001.

%%% Tuning Setup
% When the control system is modeled in Simulink, you can use the slTuner interface to quickly set up the tuning task. 
% Open the Simulink model of the autopilot.

open_system('rct_concorde')

figure
imshow("concorde_demo_02.png")

% Configure the slTuner interface by listing the tuned blocks in the Simulink model (highlighted in orange). 
% This automatically picks all Linear Analysis points in the model as points of interest for analysis and tuning.

ST0 = slTuner('rct_concorde',{'Ki','Kp','Kq','Kf','RollOff'});

% This also parameterizes each tuned block and initializes the block parameters based on their values in the Simulink model. 
% Note that the four gains Ki,Kp,Kq,Kf are initialized to zero in this example. 
% By default the roll-off filter $F_{ro}(s)$ is parameterized as a generic second-order transfer function. 
% To parameterize it as

figure
imshow("concorde_demo_eq06213035636412452882.png")

% create real parameters $\zeta, \omega_n$, build the transfer function shown above, and associate it with the RollOff block.

wn = realp('wn', 3);               % natural frequency
zeta = realp('zeta',0.8);          % damping
Fro = tf(wn^2,[1 2*zeta*wn wn^2]); % parametric transfer function

setBlockParam(ST0,'RollOff',Fro)   % use Fro to parameterize "RollOff" block

%%% Design Requirements
% The autopilot must be tuned to satisfy three main design requirements:

% 1. Setpoint tracking: The response $N_z$ to the command $N_{zc}$ should closely match the response of the reference model:

figure
imshow("concorde_demo_eq07612282794029398735.png")

% This reference model specifies a well-damped response with a 2 second settling time.

% 2. High-frequency roll-off: The closed-loop response from the noise signals to $\delta_m$ should roll off past 8 rad/s with a slope of at least -40 dB/decade.

% 3. Stability margins: The stability margins at the plant input $\delta_m$ should be at least 7 dB and 45 degrees.

% For setpoint tracking, we require that the gain of the closed-loop transfer from the command $N_{zc}$ to the tracking error $e$ be small in the frequency band [0.05,5] rad/s (recall that we cannot drive the steady-state error to zero because of the plant zero at s=0). 
% Using a few frequency points, sketch the maximum tracking error as a function of frequency and use it to limit the gain from $N_{zc}$ to $e$.

Freqs = [0.005 0.05 5 50];
Gains = [5 0.05 0.05 5];
Req1 = TuningGoal.Gain('Nzc','e',frd(Gains,Freqs));
Req1.Name = 'Maximum tracking error';

% The TuningGoal.Gain constructor automatically turns the maximum error sketch into a smooth weighting function. 
% Use viewGoal to graphically verify the desired error profile.

figure
viewGoal(Req1)

% Repeat the same process to limit the high-frequency gain from the noise inputs to $\delta_m$ and enforce a -40 dB/decade slope in the frequency band from 8 to 800 rad/s

Freqs = [0.8 8 800];
Gains = [10 1 1e-4];
Req2 = TuningGoal.Gain('n','delta_m',frd(Gains,Freqs));
Req2.Name = 'Roll-off requirement';

figure
viewGoal(Req2)

% Finally, register the plant input $\delta_m$ as a site for open-loop analysis and use TuningGoal.Margins to capture the stability margin requirement.

addPoint(ST0,'delta_m')

Req3 = TuningGoal.Margins('delta_m',7,45);

%%% Autopilot Tuning
% We are now ready to tune the autopilot parameters with systune. 
% This command takes the untuned configuration ST0 and the three design requirements and returns the tuned version ST of ST0. 
% All requirements are satisfied when the final value is less than one.

[ST,fSoft] = systune(ST0,[Req1 Req2 Req3]);

% Use showTunable to see the tuned block values.

showTunable(ST)

% To get the tuned value of $F_{ro}(s)$, use getBlockValue to evaluate Fro for the tuned parameter values in ST:

Fro = getBlockValue(ST,'RollOff');
tf(Fro)

% Finally, use viewGoal to graphically verify that all requirements are satisfied.

figure('Position',[100,100,550,710])
viewGoal([Req1 Req2 Req3],ST)

%%% Closed-Loop Simulations
% We now verify that the tuned autopilot satisfies the design requirements. 
% First compare the step response of $N_z$ with the step response of the reference model $G_{ref}(s)$. 
% Again use getIOTransfer to compute the tuned closed-loop transfer from Nzc to Nz:

Gref = tf(1.7^2,[1 2*0.7*1.7 1.7^2]);    % reference model

T = getIOTransfer(ST,'Nzc','Nz');  % transfer Nzc -> Nz

figure, step(T,'b',Gref,'b--',6), grid,
ylabel('N_z'), legend('Actual response','Reference model')

% Also plot the deflection $\delta_m$ and the respective contributions of the feedforward and feedback paths:

figure
T = getIOTransfer(ST,'Nzc','delta_m');  % transfer Nzc -> delta_m
Kf = getBlockValue(ST,'Kf');            % tuned value of Kf
Tff = Fro*Kf;         % feedforward contribution to delta_m

step(T,'b',Tff,'g--',T-Tff,'r-.',6), grid
ylabel('\delta_m'), legend('Total','Feedforward','Feedback')

% Finally, check the roll-off and stability margin requirements by computing the open-loop response at $\delta_m$.

figure 
OL = getLoopTransfer(ST,'delta_m',-1); % negative-feedback loop transfer
margin(OL);
grid;
xlim([1e-3,1e2]);

% The Bode plot confirms a roll-off of -40 dB/decade past 8 rad/s and indicates gain and phase margins in excess of 10 dB and 70 degrees.
