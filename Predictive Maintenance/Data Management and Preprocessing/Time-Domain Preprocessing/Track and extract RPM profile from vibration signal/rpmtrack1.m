%%% Track and extract RPM profile from vibration signal

%% RPM Profile of Vibration Signal
% Generate a vibration signal with three harmonic components. The signal is sampled at 1 kHz for 16 seconds. The signal's instantaneous frequency resembles the runup and coastdown of an engine. Compute the instantaneous phase by integrating the frequency using the trapezoidal rule.
fs = 1000;
t = 0:1/fs:16;

ifq = 20 + t.^6.*exp(-t);
phi = 2*pi*cumtrapz(t,ifq);

% The harmonic components of the signal correspond to orders 1, 2, and 3. The order-2 sinusoid has twice the amplitude of the others.
ol = [1 2 3];
amp = [5 10 5];

vib = amp*cos(ol'.*phi);

% Extract and visualize the RPM profile of the signal using a point on the order-2 ridge.
time = 3;
order = 2;
p = [time order*ifq(t==time)];

rpmtrack(vib,fs,order,p)

%% RPM Profile of Revving Engine
% Generate a signal that resembles the vibrations caused by revving a car engine. 
% The signal is sampled at 1 kHz for 30 seconds and contains three harmonic components of orders 1, 2.4, and 3, with amplitudes 5, 4, and 0.5, respectively. 
% Embed the signal in unit-variance white Gaussian noise and store it in a MATLAB® timetable. 
% Multiply the instantaneous frequency by 60 to obtain an RPM profile. 
% Plot the RPM profile.

fs = 1000;
t = (0:1/fs:30)';
fit = @(a,x) (t-x).^6.*exp(-(t-x)).*((t-x)>=0)*a';

fis = fit([0.4 1 0.6 1],[0 6 13 17]);
phi = 2*pi*cumtrapz(t,fis);

ol = [1 2.4 3];
amp = [5 4 0.5]';
vib = cos(phi.*ol)*amp + randn(size(t));

xt = timetable(seconds(t),vib);

figure
plot(t,fis*60)

% Derive the RPM profile from the vibration signal. 
% Use four points at 5 second intervals to specify the ridge corresponding to order 2.4. 
% Display a summary of the output timetable.
ndx = (5:5:20)*fs;
order = ol(2);

p = [t(ndx) order*fis(ndx)];

rpmest = rpmtrack(xt,order,p);

summary(rpmest)

% Plot the reconstructed RPM profile and the points used in the reconstruction.
hold on
plot(seconds(rpmest.tout),rpmest.rpm,'.-')
plot(t(ndx),fis(ndx)*60,'ok')
hold off
legend('Original','Reconstructed','Ridge points','Location','northwest')

% Use the extracted RPM profile to generate the order-RPM map of the signal.
rpmordermap(vib,fs,rpmest.rpm)

% Reconstruct and plot the time-domain waveforms that compose the signal. Zoom in on a time interval occurring after the transients have decayed.
xrc = orderwaveform(vib,fs,rpmest.rpm,ol);

figure
plot(t,xrc)
legend([repmat('Order = ',[3 1]) num2str(ol')])
xlim([5 20])

%% Fan Switchoff RPM Profile
% Estimate the RPM profile of a fan blade as it slows down after switchoff.

% An industrial roof fan spinning at 20,000 rpm is turned off. 
% Air resistance (with a negligible contribution from bearing friction) causes the fan rotor to stop in approximately 6 seconds. 
% A high-speed camera measures the x-coordinate of one of the fan blades at a rate of 1 kHz.
fs = 1000;
t = 0:1/fs:6-1/fs;

rpm0 = 20000;

% Idealize the fan blade as a point mass circling the rotor center at a radius of 50 cm. The blade experiences a drag force proportional to speed, resulting in the following expression for the phase angle

figure
imshow("Opera Snapshot_2023-01-16_120829_www.mathworks.com.png")

% where f_0 is the initial frequency and T=0.75 second is the decay time.
a = 0.5;
f0 = rpm0/60;
T = 0.75;

phi = 2*pi*f0*T*(1-exp(-t/T));

% Compute and plot the x- and y-coordinates of the blade. Add white Gaussian noise of variance 0.1^2.
x = a*cos(phi) + randn(size(phi))/10;
y = a*sin(phi) + randn(size(phi))/10;

figure
plot(t,x,t,y)

% Use the rpmtrack function to determine the RPM profile. Type
% rpmtrack(x,fs)
% at the command line to open the interactive figure.

% Use the slider to adjust the frequency resolution of the time-frequency map to about 11 Hz. 
% Assume that the signal component corresponds to order 1 and set the end time for ridge extraction to 3.0 seconds. 
% Use the crosshair cursor in the time-frequency map and the Add button to add three points lying on the ridge. 
% Alternatively, double-click the cursor to add the points at the locations you choose. 
% Click Estimate to track and extract the RPM profile.

figure
imshow("FanSwitchoffRPMProfileExample_03.png")

% Verify that the RPM profile decays exponentially. 
% On the Export tab, click Export and select Generate MATLAB Script. 
% The script appears in the Editor.

% Run the script. Display the RPM profile in a semilogarithmic plot.
% semilogy(tOut,rpmOut)
% ylim([500 20000])
