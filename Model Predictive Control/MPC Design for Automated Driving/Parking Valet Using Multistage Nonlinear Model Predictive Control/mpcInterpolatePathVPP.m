function xRef = mpcInterpolatePathVPP(path,targetPose,nPoints,nLastStep)
% This script interpolates the planned path into a trajectory for the
% tracking controller

% Copyright 2021-2022 The MathWorks, Inc.

%% Use the planned path from the NLMPC planner

x2 = path(:,1);
y2 = path(:,2);
theta2 = path(:,3);

%% Uniformly insert more waypoints to the planned path
xRef = zeros(nPoints*(numel(x2)-1)+1 + nLastStep,size(path,2));

for i = 1:numel(x2)-1
    x2_inter = x2(i)+(0:nPoints-1)*(x2(i+1)-x2(i))/nPoints;
    y2_inter = interp1([x2(i) x2(i+1)],[y2(i) y2(i+1)],x2_inter);
    theta2_inter = theta2(i)+(0:nPoints-1)*(theta2(i+1)-theta2(i))/nPoints;
    xRef((i-1)*nPoints+1:i*nPoints,:) = ...
        [x2_inter' y2_inter' theta2_inter'];
end
xRef(nPoints*(numel(x2)-1)+1,:) = path(end,:);

% Extend to the target pose
x2_inter = x2(end)+(0:nLastStep-1)*(targetPose(1)-x2(end))/nLastStep;
y2_inter = targetPose(2)*ones(1,nLastStep);
theta2_inter = theta2(end)+(0:nLastStep-1)*(targetPose(3)-theta2(end))/nLastStep;
xRef(end-nLastStep+1:end,:) = ...
    [x2_inter' y2_inter' theta2_inter'];


