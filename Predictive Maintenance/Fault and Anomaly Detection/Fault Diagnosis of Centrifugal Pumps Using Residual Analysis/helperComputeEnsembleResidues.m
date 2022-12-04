function R = helperComputeEnsembleResidues(Ensemble,Ts,sys,x1,x2,x3,x4,x5)
%helperComputeEnsembleResidues Compute residues for a given dataset ensemble.
% This function is only in support of
% CentrifugalPumpFaultDiagnosisUsingResidualAnalysisExample. It may change
% in a future release.

%  Copyright 2017 The MathWorks, Inc.

load_system('LPV_pump_pipe')
N = numel(Ensemble);
r1 = cell(N,1);
r2 = r1;
r3 = r1;
r4 = r1;
for kexp = 1:N
   [r1{kexp},r2{kexp},r3{kexp},r4{kexp}] = ...
      localComputeResidue(Ensemble{kexp},Ts,sys,x1,x2,x3,x4,x5);
end
R = [r1,r2,r3,r4];

%--------------------------------------------------------------------------
function [r1,r2,r3,r4] = localComputeResidue(Data,Ts,sys,x1,x2,x3,x4,x5)
% Residues for one dataset.
w = Data.Speed;
I1 = w<=900;
I2 = w>900 & w<=1500;
I3 = w>1500;
rho = 1800;
g = 9.81;
dp = Data.Head*rho*g;
Q = Data.Discharge;
Mmot = Data.MotorTorque;

dpest = NaN(size(dp));
dpest(I1) = [w(I1).^2 w(I1)]*[x1(1); x2(1)];
dpest(I2) = [w(I2).^2 w(I2)]*[x1(2); x2(2)];
dpest(I3) = [w(I3).^2 w(I3)]*[x1(3); x2(3)];
r1 = dp - dpest;

Switch = ones(size(w));
Switch(I2) = 2;
Switch(I3) = 3;
assignin('base', 'Switch', Switch);
assignin('base', 'UseEstimatedP', 0);
Qest_pipe = simulatePumpPipeModel(Ts,x3,x4,x5);
r2 = Q - Qest_pipe;

assignin('base', 'UseEstimatedP', 1);
Qest_pump_pipe = simulatePumpPipeModel(Ts,x3,x4,x5);
r3 = Q - Qest_pump_pipe;

zv = iddata(Mmot,[w Q/3600],Ts);
e = pe(sys,zv); 
r4 = e.y;
