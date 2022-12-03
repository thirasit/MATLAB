function helperPlotHistogram(Theta1, Theta2, Theta3, names)
%helperPlotHistogram Plot histograms of pump parameters.
%
% This function is only in support of
% CentrifugalPumpFaultDiagnosisUsingSteadyStateExperimentsExample. It may
% change in a future release.

% Copyright 2017 The MathWorks, Inc.
f = figure;
subplot(311)
localAdjustMarkers(histfit(Theta1(:,1)));
hold on
localAdjustMarkers(histfit(Theta2(:,1)))
localAdjustMarkers(histfit(Theta3(:,1)))
ylabel(names{1})
if strcmp(names{1},'hnn')
   title('Fault Mode Histograms: Head Parameters')
else
   title('Fault Mode Histograms: Torque Parameters')
end
L = findall(gca,'Type','line','Tag','PDF');
uistack(L,'top');

subplot(312)
hg = histfit(Theta1(:,2));
hasbehavior(hg(2),'legend',false)
localAdjustMarkers(hg)
hold on
hg = histfit(Theta2(:,2));
hasbehavior(hg(2),'legend',false)
localAdjustMarkers(hg)
hg = histfit(Theta3(:,2));
hasbehavior(hg(2),'legend',false);
localAdjustMarkers(hg)
ylabel(names{2})
legend('Healthy','Large', 'Small')
L = findall(gca,'Type','line','Tag','PDF');
uistack(L,'top');

subplot(313)
localAdjustMarkers(histfit(Theta1(:,3)))
hold on
localAdjustMarkers(histfit(Theta2(:,3)))
localAdjustMarkers(histfit(Theta3(:,3)))
ylabel(names{3})
L = findall(gca,'Type','line','Tag','PDF');
uistack(L,'top');

f.Position(4) = f.Position(4)*1.8571;
centerfig(f)

%--------------------------------------------------------------------------
function localAdjustMarkers(hh)
% Configure PDF curve markers to improve discernment.

Col = hh(1).FaceColor;
hh(2).Color = Col*0.7;
hh(1).FaceColor = min(Col*1.2,[1 1 1]);
hh(1).EdgeColor = Col*0.9;
hh(1).FaceAlpha = 0.5;
hh(2).Tag = 'PDF';
