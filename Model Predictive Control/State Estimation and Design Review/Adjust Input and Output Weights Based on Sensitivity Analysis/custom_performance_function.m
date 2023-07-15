function J = custom_performance_function(mpcobj, PerformanceWeights, Tsteps, r)
% This is an example of how to write a user defined performance function
% used by the "sensitivity" method.  In this example, the code illustrate
% how we use performance weights to compute the cumulative performance index.

% Copyright 1990-2014 The MathWorks, Inc.

% Carry out simulation 
[y,t,u] = sim(mpcobj, Tsteps, r);
du = [u(1,:);diff(u)];

% Get Weights in mpcobj
ny = size(mpcobj,'mo') + size(mpcobj,'uo');
nmv = size(mpcobj,'mv');
Wy = PerformanceWeights.OutputVariables(:);Wy=Wy(1:ny);
Wu = PerformanceWeights.ManipulatedVariables(:);Wu=Wu(1:nmv);
Wdu = PerformanceWeights.ManipulatedVariablesRate(:);Wdu=Wdu(1:nmv);

% Set mv target to 0
utarget=zeros(nmv,1);

% Compute J in ISE form
J=0;
aux=(y-r)*Wy;
J=J+aux'*aux;
aux=(u-ones(Tsteps,1)*utarget')*Wu;
J=J+aux'*aux;
aux=du*Wdu;
J=J+aux'*aux;

