%% Time-Domain Characteristics on Response Plots

% This example shows how to display system characteristics such as settling time and overshoot on step response plots.
% You can use similar procedures to display system characteristics on impulse response plots or initial value response plots, such as peak response or settling time.
% Create a transfer function model and plot its response to a step input at t = 0.

figure
H = tf([8 18 32],[1 6 14 24]);
stepplot(H)

% Display the peak response on the plot.
% Right-click anywhere in the figure and select Characteristics > Peak Response from the menu.

figure
imshow("timedomainanalysis3.png")

% A marker appears on the plot indicating the peak response. 
% Horizontal and vertical dotted lines indicate the time and amplitude of that response.

figure
imshow("timedomainanalysis4.png")

% Click the marker to view the value of the peak response and the overshoot in a datatip.

figure
imshow("timedomainanalysis5.png")

% You can use a similar procedure to select other characteristics such as settling time and rise time from the Characteristics menu and view the values.
