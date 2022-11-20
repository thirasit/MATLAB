% Compare speed output after tuning controller
load('SystunedSpeed')

speed_ref_oneside = logsout_tuned_oneside.getElement(1);
speed_original_oneside = logsout_original_oneside.getElement(2);
speed_tuned_oneside = logsout_tuned_oneside.getElement(2);

% Plot a comparison of speed
figure
plot(speed_original_oneside.Values);
hold on
plot(speed_tuned_oneside.Values);
plot(speed_ref_oneside.Values);
title('Compare Speed Output of Controllers');
legend('Original Controller','Tuned Controller','Speed Reference','Location','southeast');
grid on
hold off

speed_ref = logsout_tuned_twoside.getElement(1);
speed_original = logsout_original_twoside.getElement(2);
speed_tuned = logsout_tuned_twoside.getElement(2);

% Plot a comparison of speed
figure
plot(speed_original.Values);
hold on
plot(speed_tuned.Values);
plot(speed_ref.Values);
title('Compare Speed Output of Controllers');
legend('Original Controller','Tuned Controller','Speed Reference');
grid on
hold off
