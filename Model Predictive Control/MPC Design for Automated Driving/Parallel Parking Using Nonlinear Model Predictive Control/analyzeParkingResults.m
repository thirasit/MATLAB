function analyzeParkingResults(nlobj,info,ref,Qp,Rp,Qt,Rt,distToCenter,safetyDistance,timeVal)
% Analyze parking results from mpc. 

% Copyright 2019 The MathWorks, Inc.

fprintf('Summary of results:\n')
%%
% Collision checking
data.PredictionHorizon = nlobj.PredictionHorizon;
cineq = parkingIneqConFcn(info.Xopt,info.MVopt,[],data,ref,Qp,Rp,Qt,Rt,distToCenter,safetyDistance);
if all(cineq<=0)
    fprintf('1) Valid results. No collisions.\n')
else
    fprintf('1) Invalid results. Collisions.\n')
end

%%
% Distance to obstacles
minObsDist = min(-cineq + safetyDistance);
fprintf('2) Minimum distance to obstacles = %.4f (Valid when greater than safety distance %.4f)\n', minObsDist,safetyDistance);

%%
% mpc solver exit flag
flag = info.ExitFlag;
fprintf('3) Optimization exit flag = %d (Successful when positive)\n', flag);
fprintf('4) Elapsed time (s) for nlmpcmove = %.4f\n',timeVal);

%%
% final position of ego
e1 = info.Xopt(end,1)-ref(1);
e2 = info.Xopt(end,2)-ref(2);
e3 = rad2deg(info.Xopt(end,3)-ref(3));
fprintf('5) Final states error in x (m), y (m) and theta (deg):  %2.4f, %2.4f, %2.4f\n',e1,e2,e3);

%% 
% final controller values
vFinal = info.MVopt(end,1);
deltaFinal = rad2deg(info.MVopt(end,2));
fprintf('6) Final control inputs speed (m/s) and steering angle (deg): %2.4f, %2.4f\n', vFinal,deltaFinal);

end