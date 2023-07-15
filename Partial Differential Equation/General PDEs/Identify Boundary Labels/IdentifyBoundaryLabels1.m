%% Identify Boundary Labels
% You can see the edge labels by using the pdegplot function with the EdgeLabels name-value pair set to "on":
%pdegplot(g,"EdgeLabels","on")
% For 3-D problems, set the FaceLabels name-value pair to "on".
% For example, look at the edge labels for a simple geometry:
figure
e1 = [4;0;0;1;.5;0]; % Outside ellipse
e2 = [4;0;0;.5;.25;0]; % Inside ellipse
ee = [e1 e2]; % Both ellipses
lbls = char('outside','inside'); % Ellipse labels
lbls = lbls'; % Change to columns
sf = 'outside-inside'; % Set formula
dl = decsg(ee,sf,lbls); % Geometry now done
pdegplot(dl,"EdgeLabels","on")
