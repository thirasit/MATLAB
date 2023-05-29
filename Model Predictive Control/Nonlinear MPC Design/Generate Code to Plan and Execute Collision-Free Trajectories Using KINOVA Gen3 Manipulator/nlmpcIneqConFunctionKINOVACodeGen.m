function cineq = nlmpcIneqConFunctionKINOVACodeGen(X,U,e,data, numJoints, poseFinal, Qr, Qt, Qu, Qv, safetyDistance, numBodies, numObstacles, posesNow)
%#codegen

% Copyright 2020-2022 The MathWorks, Inc.

    persistent robot world poses
    
    if isempty(robot)
        robot = loadrobot('kinovaGen3', 'DataFormat', 'column');  
        [world, ~] = helperCreateObstaclesKINOVACodeGen(posesNow);
        poses = posesNow;
    end 
    
    if any(poses~=posesNow)
        world{1}.Pose = trvec2tform(posesNow(1,:));
        world{2}.Pose = trvec2tform(posesNow(2,:));
        poses = posesNow;
    end    
 
    p = data.PredictionHorizon;
   
    allDistances = zeros(p*numBodies*numObstacles,1);
    for i =1:p
        collisionConfig = X(i+1,1:numJoints);
        [~, separationDist, ~] = checkCollision(robot, collisionConfig', world, 'IgnoreSelfCollision', 'On', 'Exhaustive', 'on', 'SkippedSelfCollisions','parent');
        tempDistances = separationDist(1:robot.NumBodies,1:numObstacles);
        tempDistances(isinf(tempDistances)|isnan(tempDistances)) = 1e6;
        allDistances((1+(i-1)*numBodies*numObstacles):numBodies*numObstacles*i,1) = reshape(tempDistances', [numBodies*numObstacles,1]);   
    end
    cineq = -allDistances + safetyDistance;
end
