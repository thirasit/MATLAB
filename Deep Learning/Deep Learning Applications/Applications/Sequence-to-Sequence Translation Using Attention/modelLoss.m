%%% Model Loss Function
% The modelLoss function takes the encoder and decoder model parameters, a mini-batch of input data and the padding masks corresponding to the input data, and the dropout probability and returns the loss and the gradients of the loss with respect to the learnable parameters in the models.
function [loss,gradients] = modelLoss(parameters,X,T,...
    sequenceLengthsSource,maskTarget,dropout)

% Forward through encoder.
[Z,hiddenState] = modelEncoder(parameters.encoder,X,sequenceLengthsSource);

% Decoder Output.
doTeacherForcing = rand < 0.5;
sequenceLength = size(T,3);
Y = decoderPredictions(parameters.decoder,Z,T,hiddenState,dropout,...
    doTeacherForcing,sequenceLength);

% Masked loss.
Y = Y(:,:,1:end-1);
T = extractdata(gather(T(:,:,2:end)));
T = onehotencode(T,1,ClassNames=1:size(Y,1));

maskTarget = maskTarget(:,:,2:end);
maskTarget = repmat(maskTarget,[size(Y,1),1,1]);

loss = crossentropy(Y,T,Mask=maskTarget,Dataformat="CBT");

% Update gradients.
gradients = dlgradient(loss,parameters);

end
