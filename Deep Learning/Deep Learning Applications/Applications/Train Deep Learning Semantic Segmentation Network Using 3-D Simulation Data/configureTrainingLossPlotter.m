function [generatorLossPlotter, discriminatorLossPlotter] = configureTrainingLossPlotter(f)
% The helper function configureTrainingLossPlotter creates the subplots to display
% the generator and discriminator loss.
figure(f);
clf

% Update the loss plots.
subplot(1,2,1)
ylabel('Generator loss');
xlabel('Iteration');
generatorLossPlotter = animatedline('Color', [0 0.447 0.741]);
        
subplot(1,2,2)
ylabel('Discriminator loss');
xlabel('Iteration');
discriminatorLossPlotter = animatedline('Color', [0.85 0.325 0.098]);
end