% Copyright 2020 The MathWorks, Inc.

tolerance = 0.03;
jointTempFinal = info.Xopt(2,1:numJoints);
taskTempFinal = getTransform(robot, jointTempFinal', endEffector);
anglesTempFinal = rotm2eul(taskTempFinal(1:3,1:3), 'XYZ');
poseTempFinal =  [taskTempFinal(1:3,4);anglesTempFinal'];
diffTerminal = abs([poseFinal(1:3)-poseTempFinal(1:3); angdiff(poseTempFinal(4:6),poseFinal(4:6))]);
flag = ones(size(Qt,1),1) & diag(Qt);
if all(diffTerminal(flag)<tolerance)
    disp('Target configuration reached.')
    goalReached = true;
end