function updateTrainingPlots(generatorLossPlotter, discriminatorLossPlotter, iter, lossGenerator,  lossDiscriminator);
% The helper function updateTrainingPlots update training plot with 
% respective loss values.

addpoints(generatorLossPlotter, iter, lossGenerator);
addpoints(discriminatorLossPlotter, iter, lossDiscriminator);
drawnow
end