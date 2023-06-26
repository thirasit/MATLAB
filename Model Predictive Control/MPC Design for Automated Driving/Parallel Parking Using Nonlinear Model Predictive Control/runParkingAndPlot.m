% This function runs MPC for parking and analyzes results. 

% Copyright 2019 The MathWorks, Inc.

%% set iniital conditions for mpc
x0 = egoInitialPose';
u0 = [0;0];

%% generate mex
if useMex
    % generate MEX
    [coredata, onlinedata] = getCodeGenerationData(nlobj,x0,u0,paras);
    mexfcn = buildMEX(nlobj,'parkingMex',coredata,onlinedata);
end

%% nlmpcmove
if useMex
    tic;
    [mv,onlinedata,info] = mexfcn(x0,u0,onlinedata);
    timeVal = toc;
else    
    tic;
    [mv,nloptions,info] = nlmpcmove(nlobj,x0,u0,[],[],opt);
    timeVal = toc;
end

%% plot and animate
plotAndAnimateParking(info.Xopt,info.MVopt);

%% analyze results
analyzeParkingResults(nlobj,info,egoTargetPose,Qp,Rp,Qt,Rt,distToCenter,safetyDistance,timeVal);
