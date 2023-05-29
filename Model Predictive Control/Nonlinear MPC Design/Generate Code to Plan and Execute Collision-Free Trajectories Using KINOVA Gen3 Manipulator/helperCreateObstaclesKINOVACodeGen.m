function [world, numObstacles, posesNow] = helperCreateObstaclesKINOVACodeGen(posesNow)
%#codegen

% Copyright 2020 The MathWorks, Inc.

    numObstacles = 2; 
    world = cell(2,1); 
    
    aObs = collisionSphere(0.09);  
    aObs.Pose = trvec2tform(posesNow(1,:));   

    cObs = collisionSphere(0.09);  
    cObs.Pose = trvec2tform(posesNow(2,:));  

    world{1} = aObs;
    world{2} = cObs;  

end

