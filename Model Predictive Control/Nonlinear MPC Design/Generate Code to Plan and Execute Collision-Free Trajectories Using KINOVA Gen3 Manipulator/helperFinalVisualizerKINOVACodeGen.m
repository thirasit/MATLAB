% Copyright 2020 The MathWorks, Inc.

% Visualization time step
visTimeStep = 0.2;

% Low-fidelity robot model  
motionModel = jointSpaceMotionModel('RigidBodyTree', robot);

% Control robot to target trajectory points in simulation using low-fidelity model
initState = [positions(:,1);velocities(:,1)];
targetStates = [positions;velocities;accelerations]';    
[t,robotStates] = ode15s(@(t,state) helperTimeBasedStateInputsKINOVA(motionModel, timestamp, targetStates, t, state), [timestamp(1):visTimeStep:timestamp(end)], initState);

% Visualize simulation
for j=1:size(robotStates,1)
    show(robot, robotStates(j,1:numJoints)','PreservePlot', false, 'Frames', 'off');
    poseNow = getTransform(robot, robotStates(j,1:numJoints)', endEffector);
    plot3(poseNow(1,4), poseNow(2,4), poseNow(3,4),'b.','MarkerSize',20)
    if isMovingObst
        tNow = t(j);
        aPoseObsNow = interp1(timeObs,aPosesObs,tNow);
        h1.Matrix = trvec2tform(aPoseObsNow);
        bPoseObsNow = interp1(timeObs,bPosesObs,tNow);
        h2.Matrix = trvec2tform(bPoseObsNow);
    end
    drawnow;
end