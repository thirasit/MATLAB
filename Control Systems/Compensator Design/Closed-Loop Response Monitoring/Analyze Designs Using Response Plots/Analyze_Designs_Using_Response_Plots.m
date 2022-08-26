%% Analyze Designs Using Response Plots

% This example shows how to analyze your control system designs using the plotting tools in Control System Designer. 
% There are two types of Control System Designer plots:

% - Analysis plots — Use these plots to visualize your system performance and display response characteristics.
% - Editor plots — Use these plots to visualize your system performance and interactively tune your compensator dynamics using graphical tuning methods.

%%% Analysis Plots
% Use analysis plots to visualize your system performance and display response characteristics. 
% You can also use these plots to compare multiple control system designs. 
% For more information, see Compare Performance of Multiple Designs.

% To create a new analysis plot, in Control System Designer, on the Control System tab, click New Plot, and select the type of plot to add.

figure
imshow("csd_analysis_select_plot.png")

% In the new plot dialog box, specify an existing or new response to plot.

%%% Plot Existing Response
% To plot an existing response, in the Select Response to Plot drop-down list, select an existing response from the Data Browser. The details for the selected response are displayed in the text box.
% To plot the selected response, click Plot.

%%% Plot New Response
% To plot a new response, specify the following:
% - Select Response to Plot — Select the type of response to create.
% - - New Input-Output Transfer Response — Create a transfer function response for specified input signals, output signals, and loop openings.
% - - New Open-Loop Response — Create an open-loop transfer function response at a specified location with specified loop openings.
% - - New Sensitivity Transfer Response — Create a sensitivity response at a specified location with specified loop openings.

% - Response Name — Enter a name in the text box.
% - Signal selection boxes — Specify signals as inputs, outputs, or loop openings by clicking . If you open Control System Designer from:
% - - MATLAB® — Select a signal using the Architecture block diagram for reference.
% - - Simulink® — Select an existing signal from the current control system architecture, or add a signal from the Simulink model.

% To add the specified response to the Data Browser and create the selected plot, click Plot.

%%% Editor Plots
% Use editor plots to visualize your system performance and interactively tune your compensator dynamics using graphical tuning methods.
% To create a new editor plot, in Control System Designer, on the Control System tab, click Tuning Methods, and select one of the Graphical Tuning methods.

figure
imshow("csd_analysis_select_editor.png")

% For examples of graphical tuning using editor plots, see:
% - Bode Diagram Design
% - Root Locus Design
% - Nichols Plot Design

% For more information on interactively editing compensator dynamics, see Edit Compensator Dynamics.

%%% Plot Characteristics
% On any analysis plot in Control System Designer:
% - To see response information and data values, click a line on the plot.

figure
imshow("csd_analysis_data_values.png")

% - To view system characteristics, right-click anywhere on the plot, as described in Frequency-Domain Characteristics on Response Plots.

figure
imshow("csd_analysis_characteristics.png")

%%% Plot Tools
% Mouse over any analysis plot to access plot tools at the upper right corner of the plot.

figure
imshow("csd_analysis_plot_tools.png")

% - + and — Zoom in and zoom out. Click to activate, and drag the cursor over the region to zoom. The zoom icon turns dark when zoom is active. Right-click while zoom is active to access additional zoom options. Click the icon again to deactivate.

figure
imshow("csd_analysis_zoom.png")

% — Pan. Click to activate, and drag the cursor across the plot area to pan. The pan icon turns dark when pan is active. Right-click while pan is active to access additional pan options. Click the icon again to deactivate.

% — Legend. By default, the plot legend is inactive. To toggle the legend on and off, click this icon. To move the legend, drag it to a new location on the plot.

% To change the way plots are tiled or sorted, click and drag the plots to the desired location.

%%% Design Requirements
% You can add graphical representations of design requirements to any editor or analysis plots. These requirements define shaded exclusion regions in the plot area.

figure
imshow("csd_analysis_requirement.png")

% Use these regions as guidelines when analyzing and tuning your compensator designs. To meet a design requirement, your response plots must remain outside of the corresponding shaded area.

% To add design requirements to a plot, right-click anywhere on the plot and select Design Requirements > New.

figure
imshow("csd_requirements_add.png")

% In the New Design Requirement dialog box, specify the Design requirement type, and define the Design requirement parameters. 
% Each type of design requirement has a different set of parameters to configure. 
% For more information on adding design requirements to analysis and editor plots, see Design Requirements.
