%%% Plot Results Function
% This helper function plots the temperature distribution, radial stress, hoop stress, and von Mises stress.
function plotResults(model,R,modelT,Rt,tID)
figure
subplot(2,2,1)
pdeplot(modelT,"XYData",Rt.Temperature(:,tID), ...
               "ColorMap","jet","Contour","on")
title({'Temperature'; ...
      ['max = ' num2str(max(Rt.Temperature(:,tID))) '^{\circ}C']})
xlabel("r, m")
ylabel("z, m")

subplot(2,2,2)
pdeplot(model,"XYData",R.Stress.srr, ...
              "ColorMap","jet","Contour","on")
title({'Radial Stress'; ...
       ['min = ' num2str(min(R.Stress.srr)/1E6,'%3.2f') ' MPa']; ...
       ['max = ' num2str(max(R.Stress.srr)/1E6,'%3.2f') ' MPa']})
xlabel("r, m")
ylabel("z, m")

subplot(2,2,3)
pdeplot(model,"XYData",R.Stress.sh, ...
              "ColorMap","jet","Contour","on")
title({'Hoop Stress'; ...
      ['min = ' num2str(min(R.Stress.sh)/1E6,'%3.2f') ' MPa']; ...
      ['max = ' num2str(max(R.Stress.sh)/1E6,'%3.2f') ' MPa']})
xlabel("r, m")
ylabel("z, m")

subplot(2,2,4)
pdeplot(model,"XYData",R.VonMisesStress, ...
              "ColorMap","jet","Contour","on")
title({'Von Mises Stress'; ...
      ['max = ' num2str(max(R.VonMisesStress)/1E6,'%3.2f') ' MPa']})
xlabel("r, m")
ylabel("z, m")

sgtitle(['Time = ' num2str(Rt.SolutionTimes(tID)) ' s'])
end