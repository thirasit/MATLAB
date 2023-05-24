function [X,Y,MV,eTime] = fedbatch_Track(nlmpcobj, x0, mv0, N, Cref, MD)
% Helper function of the "fedbatch" example.  It uses a specified
% controller to track a specified C production profile using the standard
% nonlinear MPC cost function.

% Copyright 2018 The MathWorks, Inc.

X = zeros(N+1,4);
Y = zeros(N+1,3);
MV = zeros(N+1,1);
X(1,:) = x0(:)';
Y(1,:) = fedbatch_OutputFcn(X(1,:)', [MD(1,1); mv0; MD(1,2)])';
mv = mv0;
opts = nlmpcmoveopt;
p = nlmpcobj.PredictionHorizon; % default to 10
t0 = tic;
for k = 1:N
    nref = min(N+1,k+p);
    ref = [Cref(k+1:nref) zeros(nref-k,2)];
    md = MD(k:nref,:);
    [mv, opts] = nlmpcmove(nlmpcobj, X(k,:)', mv, ref, md, opts);
    MV(k,:) = mv';
    % Use discrete-time model to represent the plant
    u = [md(1,1); mv; md(1,2)];
    X(k+1,:) = fedbatch_StateFcnDT(X(k,:)', u, nlmpcobj.Ts)';
    Y(k+1,:) = fedbatch_OutputFcn(X(k+1,:)', u)';
end
MV(N+1,:) = mv';
eTime = toc(t0);