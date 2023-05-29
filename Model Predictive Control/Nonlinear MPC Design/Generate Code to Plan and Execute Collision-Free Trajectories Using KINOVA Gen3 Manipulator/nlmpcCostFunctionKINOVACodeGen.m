function cost = nlmpcCostFunctionKINOVACodeGen(X,U,e,data, numJoints, poseFinal, Qr, Qt, Qu, Qv, safetyDistance, numBodies,  numObstacles, posesNow)
%#codegen

% Copyright 2020 The MathWorks, Inc.

    persistent robot endEffector
    
    if isempty(robot)
        robot = loadrobot('kinovaGen3', 'DataFormat', 'column'); 
        endEffector = 'EndEffector_Link';
    end
    
    % Running Cost
  
    p = data.PredictionHorizon;
   
    costRunning = 0;
    diffRunning = zeros(6,1);
    for i= 2:p+1
        jointTemp = X(i,1:numJoints);
        taskTemp = getTransform(robot, jointTemp', endEffector);
        anglesTemp = rotm2eul(taskTemp(1:3,1:3), 'XYZ');
        poseTemp =  [taskTemp(1:3,4);anglesTemp'];
        diffRunning = [poseFinal(1:3)-poseTemp(1:3); angdiff(poseTemp(4:6),poseFinal(4:6))];
        costRunningTemp = diffRunning' * Qr * diffRunning;
        costRunning = costRunning + costRunningTemp + U(i,:)*Qu*U(i,:)';
    end
    
    % Terminal cost
    costTerminal = diffRunning'* Qt * diffRunning + X(p+1,numJoints+1:end)*Qv*X(p+1,numJoints+1:end)';

    % Total Cost
    cost = costRunning + costTerminal;
end