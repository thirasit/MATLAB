function [T, MinMax] = helperGenerateFeatureTable(Ensemble, CandidateFeatures, Names, MinMax)
%helperGenerateFeatureTable Extract features from residues.
% This function is only in support of
% CentrifugalPumpFaultDiagnosisUsingResidualAnalysisExample. It may change
% in a future release.

%  Copyright 2018 The MathWorks, Inc.

[N,m] = size(Ensemble); % N experiments, m residues
nf = length(Names); % nf features
F = zeros(N,m*nf);
ColNames = cell(1,m*nf);
for j = 1:nf
   fcn = CandidateFeatures{j};
   F(:,(j-1)*m+(1:m)) = cellfun(@(x)fcn(x),Ensemble,'uni',1);
   ColNames((j-1)*m+(1:m)) = strseq(Names{j},1:m);
end
if nargout>1 && nargin<4
   MinMax = [min(F); max(F)];
end

if nargin>3 || nargout>1
   Range = diff(MinMax);
   F = (F-MinMax(1,:))./Range;
end
T = array2table(F,'VariableNames',ColNames);
