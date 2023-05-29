function [C, D] = nlmpcJacobianOutputKINOVACodeGen(x,u, numJoints, poseFinal, Qr, Qt, Qu, Qv, safetyDistance, numBodies,  numObstacles, posesNow)
    %#codegen
    
    % Copyright 2020 The MathWorks, Inc.

    C = zeros(numJoints, numJoints * 2);
    C(1:numJoints, 1:numJoints) = eye(numJoints);
    D = zeros(numJoints, numJoints);
end