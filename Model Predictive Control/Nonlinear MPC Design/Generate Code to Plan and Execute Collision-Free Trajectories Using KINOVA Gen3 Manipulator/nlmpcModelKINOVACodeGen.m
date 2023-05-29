function dxdt = nlmpcModelKINOVACodeGen(x,u, numJoints, poseFinal, Qr, Qt, Qu, Qv, safetyDistance, numBodies, numObstacles, posesNow)
    %#codegen
    
    % Copyright 2020 The MathWorks, Inc.

    dxdt = zeros(size(x));
    dxdt(1:numJoints) = x(numJoints+1:end);
    dxdt(numJoints+1:end) = u;
end