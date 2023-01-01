%%% Update posterior parameter distribution of degradation remaining useful life model

%% Update Exponential Degradation Model in Real Time
% Load training data, which is a degradation feature profile for a component.
load('expRealTime.mat')

% For this example, assume that the training data is not historical data. When there is no historical data, you can update your degradation model in real time using observed data.
% Create an exponential degradation model with the following settings:
% - Arbitrary θ and β prior distributions with large variances so that the model relies mostly on observed data
% - Noise variance of 0.003
mdl = exponentialDegradationModel('Theta',1,'ThetaVariance',1e6,...
                                  'Beta',1,'BetaVariance',1e6,...
                                  'NoiseVariance',0.003);

% Since there is no life time variable in the training data, create an arbitrary life time vector for fitting.
lifeTime = [1:length(expRealTime)];

% Observe the degradation feature for 10 iterations. Update the degradation model after each iteration.
for i=1:10
    update(mdl,[lifeTime(i) expRealTime(i)])
end

% After observing the model for some time, for example at a steady-state operating point, you can restart the model and save the current posterior distribution as a prior distribution.
restart(mdl,true)

% View the updated prior distribution parameters.
mdl.Prior
