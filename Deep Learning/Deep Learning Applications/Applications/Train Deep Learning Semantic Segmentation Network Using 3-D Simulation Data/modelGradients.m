%%% Model Gradients Function
% The helper function modelGradients calculates the gradients and adversarial loss for the generator and discriminator.
% The function also calculates the segmentation loss for the generator and the cross-entropy loss for the discriminator.
% As no state information is required to be remembered between the iterations for both generator and discriminator networks, the states are not updated.
function [gradientGenerator, gradientDiscriminator, lossSegValue, lossAdvValue, lossDisValue] = modelGradients(dlnetGenerator, dlnetDiscriminator, dlX, dlZ, label, lamdaAdv)

% Labels for adversarial training.
simulationLabel = 0;
realLabel = 1;

% Extract the predictions of the simulation from the generator.
[genPredictionSimulation, ~] = forward(dlnetGenerator,dlX);

% Compute the generator loss.
lossSegValue = segmentationLoss(genPredictionSimulation,label);

% Extract the predictions of the real data from the generator.
[genPredictionReal, ~] = forward(dlnetGenerator,dlZ);

% Extract the softmax predictions of the real data from the discriminator.
disPredictionReal = forward(dlnetDiscriminator,softmax(genPredictionReal));

% Create a matrix of simulation labels of real prediction size.
Y = simulationLabel * ones(size(disPredictionReal));

% Compute the adversarial loss to make the real distribution close to the simulation label.
lossAdvValue = mse(disPredictionReal,Y)/numel(Y(:));

% Compute the gradients of the generator with regard to loss.
gradientGenerator = dlgradient(lossSegValue + lamdaAdv*lossAdvValue,dlnetGenerator.Learnables);

% Extract the softmax predictions of the simulation from the discriminator.
disPredictionSimulation = forward(dlnetDiscriminator,softmax(genPredictionSimulation));

% Create a matrix of simulation labels of simulation prediction size.
Y = simulationLabel * ones(size(disPredictionSimulation));

% Compute the discriminator loss with regard to simulation class.
lossDisValueSimulation = mse(disPredictionSimulation,Y)/numel(Y(:));
 
% Extract the softmax predictions of the real data from the discriminator.
disPredictionReal = forward(dlnetDiscriminator,softmax(genPredictionReal));

% Create a matrix of real labels of real prediction size.
Y = realLabel * ones(size(disPredictionReal));

% Compute the discriminator loss with regard to real class.
lossDisValueReal = mse(disPredictionReal,Y)/numel(Y(:));

% Compute the total discriminator loss.
lossDisValue = lossDisValueSimulation + lossDisValueReal;

% Compute the gradients of the discriminator with regard to loss.
gradientDiscriminator = dlgradient(lossDisValue,dlnetDiscriminator.Learnables);

end
