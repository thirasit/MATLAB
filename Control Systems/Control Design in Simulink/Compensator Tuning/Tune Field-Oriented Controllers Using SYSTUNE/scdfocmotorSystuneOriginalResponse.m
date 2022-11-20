% Examine speed response with original controllers
% Follow speed command in one direction
signalbuilder(SignalBuilderPath, 'activegroup', 2);
sim(mdl);
logsout_original_oneside = logsout;
save('SystunedSpeed','logsout_original_oneside')

% Follow speed command in two directions
signalbuilder(SignalBuilderPath, 'activegroup', 3);
sim(mdl);
logsout_original_twoside = logsout;
save('SystunedSpeed','logsout_original_twoside','-append')
