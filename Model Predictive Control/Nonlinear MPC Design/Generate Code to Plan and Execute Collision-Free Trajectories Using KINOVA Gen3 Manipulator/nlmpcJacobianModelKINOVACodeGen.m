function [A, B] = nlmpcJacobianModelKINOVACodeGen(x,u, numJoints, poseFinal, Qr, Qt, Qu, Qv, safetyDistance, numBodies,  numObstacles, posesNow)
    %#codegen
    
    % Copyright 2020 The MathWorks, Inc.

    A = zeros(numJoints*2, numJoints * 2);    
    A(1:numJoints, numJoints+1:end) = eye(numJoints);
    B = zeros(numJoints*2,numJoints);
    B(numJoints+1:end,:)=eye(numJoints); 
end