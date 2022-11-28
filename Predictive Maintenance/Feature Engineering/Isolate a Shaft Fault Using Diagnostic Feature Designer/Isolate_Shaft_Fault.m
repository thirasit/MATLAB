%% Isolate a Shaft Fault Using Diagnostic Feature Designer

% This example shows how to isolate a shaft fault from simulated measurement data for machines with varying rotation speeds and develop features that can help detect the fault.

% The example assumes that you are already familiar with basic operations with the app. For a tutorial on using the app, see Identify Condition Indicators for Predictive Maintenance Algorithm Design.

%%% Model Description
% The following figure illustrates a drivetrain with six gears. 
% The motor for the drivetrain is fitted with a vibration sensor and a tachometer. 
% In this drivetrain:

% - Gear 1 on the motor shaft meshes with gear 2 with a gear ratio of 17:1.
% - The final gear ratio, or the ratio between gears 1 and 2 and gears 3 and 4, is 51:1.
% - Gear 5, also on the motor shaft, meshes with gear 6 with a gear ratio of 10:1.

figure
imshow("tsa_ref_page_example_1800rpm_tacho.png")

% Twenty simulated machines use this drivetrain. 
% Each machine operates with a nominal rotation speed within 1 percent of the design rotation speed of 1800 rpm. 
% Therefore, the nominal rotation speed for each machine ranges between 1782 rpm and 1818 rpm.

% Ten of the machines include a fault developing on the shaft of gear 6.

%%% Import and Examine Measurement Data
% To start, load the data into your MATLAB® workspace and open Diagnostic Feature Designer.

load(fullfile(matlabroot, 'toolbox', 'predmaint', 'predmaintdemos', ...
  'motorDrivetrainDiagnosis', 'machineData3'), 'motor_data')
diagnosticFeatureDesigner

% Import the data. To do so, in the Feature Designer tab, click New Session. Then, in the Select more variables of the New Session window, select motor_data as your source variable.

figure
imshow("import_dt_new_session_button.png")

figure
imshow("dfd_rpm_load_motor_data.png")

% Complete the import process by accepting the default configuration and variables. 
% The ensemble includes two data variables—Signal/vib, which contains the vibration signal, and Tacho/pulse, which contains the tachometer pulses. 
% The ensemble also includes the condition variable Health.

% In the Data Browser, select both signals and plot them together using Signal Trace.

figure
imshow("dfd_rpm_vibtacho_plot_707.png")

% Note that the Tacho pulse clusters widen with each pulse because of rotation-speed variation. 
% If the Tacho pulses are not visible, click Group Signals twice to bring the Tacho signal to the front.

% Now group the data by fault condition by selecting Ensemble View Preferences > Group by "Health". 
% Use the panner to expand a slice of the signal.

figure
imshow("dfd_rpm_groupby.png")

figure
imshow("dfd_rpm_trace_grouped.png")

% The plot shows small differences in the peaks of the groups, but the signals look similar otherwise.

%%% Perform Time-Synchronous Averaging
% Time-synchronous averaging (TSA) averages a signal over one rotation, substantially reducing noise that is not coherent with the rotation. 
% TSA-filtered signals provide the basis for much rotational-machinery analysis, including feature generation.

% In this example, the rotation speeds vary within 1 percent of the design value. 
% You capture this variation automatically when you use the Tacho signal for TSA processing.

% To compute the TSA signal, select Filtering & Averaging > Time-Synchronous Signal Averaging. 
% In the dialog box:

% - Confirm the selection in Signal.
% - In Tacho Information, select Tacho signal and confirm the signal selection.
% Select Compute nominal speed (RPM). This option results in the computation of a set of machine-specific nominal speeds, or operating points, from the Tacho signal. 
% You can use this information when you perform follow-on processing, such as TSA signal filtering. 
% Since your tachometer variable is named Tacho, the app stores these values as the condition variable Tacho_rpm.
% - Accept all other settings.

figure
imshow("dfd_rpm_tsa_dialog.png")

figure
imshow("dfd_rpm_tsa.png")

% The TSA-averaged signals are cleaner than the raw signals. 
% The peak heights are clustered by health condition, just as they were before, but the plot does not show enough information to indicate the source of the fault.

%%% Compute TSA Difference Signal
% The TSA filtering options in the app all start with a TSA signal and subtract various components from that signal to produce a filtered signal. 
% Each filtered signal type yields unique features that you can use to detect specific faults in the gear train. 
% One of these filtered signals is the difference signal. 
% The TSA difference signal contains the components that remain after you subtract all of the components that are due to the drivetrain design for components that are not in your area of interest. 
% Specifically, the TSA difference-signal processing subtracts:

% - Shaft frequency and harmonics
% - Gear-meshing frequencies and harmonics
% - Sidebands at the gear-meshing frequencies and their harmonics

% For this example, you are interested in the mesh defect between gear 5 and gear 6. 
% To focus on signals arising from this defect, filter out signals associated with the other gears. 
% To do so, use the successive gear ratios described in the model description as you move down the drivetrain. 
% The ratio between gears 1 and 2 is 17. 
% The ratio between gears 1/2 and 3/4 is 51. 
% These ratios become your rotation orders.

% To compute the TSA difference signal, select Filtering & Averaging > Filter Time-Synchronous Averaged Signals. In the dialog box:

% - Set Signal to the TSA signal Signal_tsa/vib.
% - In Signals to Generate, select Difference signal.
% - In Speed Settings, select Nominal rotation speed (RPM) and then Tacho_rpm.
% - Confirm that Domain is Order.
% - Set Rotation orders to [17 51].

figure
imshow("dfd_rpm_difference_dialog.png")

% When you group the plotted data by Health, you also see the condition variable Tacho_rpm in the option list.

figure
imshow("dfd_rpm_difference_groupby.png")

% The resulting plot shows a clear oscillation. 
% Group the data by healthy and faulty labels. 
% The oscillation is present only for the faulty machines. 
% Using the data cursors, you can show that the period of this oscillation is about 0.0033 seconds. 
% The corresponding frequency of the oscillation is about 303 Hz or 18,182 rpm. 
% This frequency has roughly a 10:1 ratio with the primary shaft speed of 1800 rpm, and is consistent with the 10:1 gear ratio between gear 5 and gear 6. 
% The difference signal therefore isolates the source of the simulated fault.

figure
imshow("dfd_rpm_difference_trace.png")

%%% Isolate the Fault Without a Tachometer Signal
% In the preceding sections, you use tachometer pulses to precisely generate TSA signals and difference signals. 
% If you do not have tachometer information, you can use a constant rpm value to generate these signals. 
% However, the results are less precise.

% See if you can isolate the defect without using the Tacho signal. Compute both the TSA signal and the difference signal with an ensemble-wide rotation speed of 1800 rpm.

figure
imshow("dfd_rpm_tsa_const_rpm_params.png")

% The new TSA signal has the name Signal_tsa_1/vib. 
% As the plot shows, generating a TSA signal without tachometer information produces a less clear signal then generating a signal with tachometer information.

figure
imshow("dfd_rpm_tsa_const_rpm_trace.png")

% Compute the difference signal using Signal_tsa_1/vib and the Constant rotation speed (RPM) setting.

figure
imshow("dfd_rpm_difference_const_rpm_params.png")

% In the resulting plot, you can still see the oscillation for the faulty set of machines, but as with the TSA signal, the oscillation is much less clear than the previous difference signal. 
% The unaccounted-for 1-percent rpm variation has a significant impact on the results.

figure
imshow("dfd_rpm_difference_const_rpm_trace.png")

%%% Extract Rotating Machinery Features
% Use the TSA and difference signals Signal_tsa/x and Signal_tsa_tsafilt/x_Difference to compute time-domain rotational machinery features.

% To compute these features, select Time-Domain Features > Rotating Machinery Features. 
% In the dialog box, select the signals to use for TSA signal and Difference signal and then select all the feature options that use TSA or difference signals.

figure
imshow("dfd_rpm_features_rotating_params.png")

% The resulting histogram plots indicate good separation between healthy and faulty groups for all of the TSA-signal-based features, and for FM4 (kurtosis) in the difference-signal-based features.

figure
imshow("dfd_rpm_features_rotating_histogram.png")

%%% Extract Spectral Features
% Since the difference signal displays a clear oscillation that is limited to the faulty group, spectral features are also likely to differentiate well between healthy and faulty groups. 
% To calculate spectral features, you must first compute a spectral model. 
% To do so, click Spectral Estimation > Order Spectrum. 
% As before, select your difference signal as Signal and your tachometer signal as Tacho signal.

figure
imshow("dfd_rpm_difference_order_spectrum_params.png")

% The resulting plot displays the oscillation of the defect as the first peak in the plot at roughly order 10.

figure
imshow("dfd_rpm_difference_order_spectrum.png")

% Compute the spectral features by clicking Spectral Features. In the dialog box:
% - Confirm the selection for Spectrum.
% - Move the order range slider to cover the range from 0 to 200. As you move the slider, the order spectrum plot incorporates the change.

figure
imshow("dfd_rpm_difference_spectral_features_params.png")

% The resulting histograms indicate good differentiation between groups for BandPower and PeakAmp. PeakFreq1 shows a small amount of group overlap.

figure
imshow("dfd_rpm_difference_spectral_features_histogram.png")

%%% Rank Features
% Rank the features using the default T-test ranking. To do so, click Rank Features and select FeatureTable1. The app automatically ranks the features and plots the scores.

% - Spectral features BandPower and PeakAmp take the two top places with scores significantly higher than the other features.
% - Rotational features Kurtosis and CrestFactor take the third and fourth places with scores much lower than the spectral features, but still significantly higher than the remaining features.
% - The remaining features are likely not useful for detecting faults of this type.

figure
imshow("dfd_rpm_ranking.png")

% Using these high-ranking features, you could now move on to export the features to Classification Learner for training or to your MATLAB workspace for algorithm incorporation.
