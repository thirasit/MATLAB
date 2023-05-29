function [G,Gmv,Ge] = nlmpcJacobianCostKINOVACodeGen(X,U,e,data, numJoints, poseFinal, Qr, Qt, Qu, Qv, safetyDistance, numBodies,  numObstacles, posesNow)
%#codegen

% Copyright 2020 The MathWorks, Inc.

    persistent robot endEffector
    
    if isempty(robot)
        robot = loadrobot('kinovaGen3', 'DataFormat', 'column'); 
        endEffector = 'EndEffector_Link';
    end
    
    p = data.PredictionHorizon;
        
   % Initialize Jacobians
    G = zeros(p,numJoints*2);
    Gmv = zeros(p,numJoints);
    Ge = 0;
    
    diffRunning = zeros(6,1);
    robotJacobian = zeros(6,numJoints);
    % Update G
    for i=1:p
        jointTemp = X(i+1,1:numJoints);
        taskTemp = getTransform(robot, jointTemp', endEffector);
        anglesTemp = rotm2eul(taskTemp(1:3,1:3), 'XYZ');
        poseTemp =  [taskTemp(1:3,4);anglesTemp'];
        diffRunning = [poseFinal(1:3)-poseTemp(1:3); angdiff(poseTemp(4:6),poseFinal(4:6))]; 
        
        % From geometric to analytical robot Jacobian
        rx = anglesTemp(1);
        py = anglesTemp(2);
        B = [ 1 0 sin(py); 0 cos(rx) -cos(py)*sin(rx); 0 sin(rx) cos(py)*cos(rx) ]; 
        
        % Robot Jacobian
        robotJacobianTemp = geometricJacobian(robot,jointTemp',endEffector);
        robotJacobian = robotJacobianTemp;
        robotJacobian(1:3,:) = robotJacobianTemp(4:6,:);
        robotJacobian(4:6,:) = B\robotJacobianTemp(1:3,:);
        
        % Running cost Jacobian
        G(i,1:numJoints) = (-2 * diffRunning' * Qr * robotJacobian); 
        Gmv(i,:) = 2 * U(i+1,:) * Qu;
    end

    % Terminal cost Jacobian
    G(p,1:numJoints) = G(p,1:numJoints) + (-2 * diffRunning' * Qt * robotJacobian);
    G(p,numJoints+1:end) = 2 * X(p+1,numJoints+1:end) * Qv;
end