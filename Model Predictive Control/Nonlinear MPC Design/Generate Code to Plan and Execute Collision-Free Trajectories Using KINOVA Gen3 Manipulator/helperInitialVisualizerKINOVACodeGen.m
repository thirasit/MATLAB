% Copyright 2020 The MathWorks, Inc.

% Initial visualizer
positions = x0(1:numJoints)';

figure('Position', [375 446 641 480]);
ax1 = show(robot, positions(:,1),'PreservePlot', false, 'Frames', 'off');
view(150,29)
hold on
axis([-0.8 0.8 -0.6 0.7 -0.2 0.7]);
plot3(poseFinal(1), poseFinal(2), poseFinal(3),'r.','MarkerSize',20)

% Visualize collision world
if isMovingObst
    poseObsTemp = [0 0 0]; % frame reference
    world{1}.Pose = trvec2tform(poseObsTemp);
    world{2}.Pose = trvec2tform(poseObsTemp);
    [~,pObject1] = show(world{1});
    pObject1.LineStyle = 'none'; 
    [~,pObject2] = show(world{2});
    pObject2.LineStyle = 'none'; 
    h1 = hgtransform;
    pObject1.Parent = h1;
    world{1}.Pose = trvec2tform(posesNow(1,:));
    h1.Matrix = world{1}.Pose;
    h2 = hgtransform;
    pObject2.Parent = h2;
    world{2}.Pose = trvec2tform(posesNow(2,:));
    h2.Matrix = world{2}.Pose;
else
    for i=1:numel(world)
        [~,pObj] = show(world{i});
        pObj.LineStyle = 'none';
    end
end



