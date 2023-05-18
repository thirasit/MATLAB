function nss = trainFlyingRobotNeuralStateSpaceModel
% This function estimate an idNeuralStateSpace model for the flying robot
% system using experiment data sets.

%% Load data sets for training
% We conduct 1001 experiments.  Each experiment lasts 1 second with sample
% time of 0.1 second.  In each experiemnt the robot starts at a random
% state and is driven a sequence of random thrust inputs.  We log data for
% both states (X) and inputs (U) and save them in a MAT file.
%%
% The first 1000 experiment is used in training and the last experiment is
% used to monitor estimation performance during training.
load nssExperimentDataSet.mat

%% Create idNeuralStateSpace Object and Set Network Parameters
% create an idNeuralStateSpace object with 6 states and 4 inputs.
obj = idNeuralStateSpace(6,NumInputs=4);
%%
% customize the state MLP network with 3 hidden layers and each 32 nodes.
obj.StateNetwork = createMLPNetwork(obj,'state',...
   LayerSizes=[32 32 32],...
   Activations='tanh',...
   WeightsInitializer="glorot",...
   BiasInitializer="zeros");

%% Choose Training Method and Options
% We use the adaptive moment estimation (ADAM) algorithm to train the state
% network in a custom training loop.  The training process takes 1000
% epochs to complete.  We often need to play with a few traning optoins to
% achieve satisfacory speed and convergence, as shown below.
options = nssTrainingOptions('adam');
options.MaxEpochs = 1000;
options.MiniBatchSize = 500;
options.LearnRate = 0.005;   
options.InputInterSample = 'zoh';

%% Use "nlssest" to train the state network
nss = nlssest(U,X,obj,options,'UseLastExperimentForValidation',true);

%% Conduct Post-Training Analysis
% After network is trained, we can evaluate the state function and
% linearize it at an arbitrary operating point.
xT = rand(6,1); uT = rand(4,1);
dxdt = evaluate(obj,xT,uT);
sys = linearize(obj,xT,uT);

