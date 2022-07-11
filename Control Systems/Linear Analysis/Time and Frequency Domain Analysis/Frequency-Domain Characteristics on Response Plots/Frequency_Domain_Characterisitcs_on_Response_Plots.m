%% Frequency-Domain Characteristics on Response Plots

% This example shows how to display system characteristics such as peak response on Bode response plots.
% You can use similar procedures to display system characteristics on other types of response plots.
% Create a transfer function model and plot its frequency response.

figure
H = tf([10,21],[1,1.4,26]); 
bodeplot(H)

% Display the peak response on the plot.
% Right-click anywhere in the figure and select Characteristics > Peak Response from the menu.

figure
imshow("freqdomainanalysis4.png")

% A marker appears on the plot indicating the peak response. 
% Horizontal and vertical dotted lines indicate the frequency and magnitude of that response. 
% The other menu options add other system characteristics to the plot.

figure
imshow("freqdomainanalysis5.png")

% Click the marker to view the magnitude and frequency of the peak response in a datatip.

figure
imshow("freqdomainanalysis6.png")
