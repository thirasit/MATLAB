function out = nlmpcOutputKINOVACodeGen(x,u, numJoints, poseFinal, Qr, Qt, Qu, Qv, safetyDistance, numBodies,  numObstacles, posesNow)
    %#codegen
    
    % Copyright 2020 The MathWorks, Inc.

    out = x(1:numJoints);
end