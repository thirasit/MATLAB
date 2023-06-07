function TruckTrailerPlot(initialPose, targetPose, params, info, XY0)
% Animate automated parking of a truck and trailer system.

% Copyright 2020-2023 The MathWorks, Inc.

% plot initial poses
f = figure('NumberTitle','off');
xlabel('x');
ylabel('y');
plot(initialPose(1), initialPose(2),'rx'); 
hold on;
plot(targetPose(1), targetPose(2),'gx'); 
% set bounds
xbound = [-50 50];
ybound = [-30 30];
xlim(xbound);
ylim(ybound);
% plot two obstacles
boxes = struct('Width',{17.5,17.5},'Height',{20,20},...
    'Pos',{[-11.25;-20],[11.25;-20]},'Theta',{0,0});
for j = 1:length(boxes)
    obsStruct = boxes(j);
    obs = collisionBox(obsStruct.Width,obsStruct.Height,0);
    obs.Pose(1:3,1:3) = eul2rotm([obsStruct.Theta 0 0]);
    obs.Pose(1:2,4) = obsStruct.Pos;
    show(obs)
end
if nargin<=3
    f.Name = 'Parking Lot with Initial and Target Positions';
    animateTractorTrailer(gca, 0, initialPose', [0 0], params);
else
    f.Name = ['Automated Parking Animation (x0 = ' num2str(initialPose(1)) ', y0 = ' num2str(initialPose(2)) ')'];
    % obtain optimal trajectory designed by MPC
    xTrackHistory = info.Xopt;
    uTrackHistory = info.MVopt;
    tTrackHistory = info.Topt;
    % plot the initial guess of XY trajectory
    plot(XY0(:,1),XY0(:,2),'c.')
    % plot the optimal XY trajectory by MPC
    plot(xTrackHistory(:,1),xTrackHistory(:,2),'bo')
    % animate track trailer moves
    animateTractorTrailer(gca, tTrackHistory, xTrackHistory, uTrackHistory(:,1), params);
    %
    legend('','','','','Initial Guess','Optimal Path');
    % plot optimal MV and states
    figure('NumberTitle','off','Name','Optimal Trajectory of MVs and States');
    subplot(3,2,1)
    plot(tTrackHistory(1:end-1),uTrackHistory((1:end-1),1));title('\alpha (rad)');grid on;
    subplot(3,2,2)
    plot(tTrackHistory(1:end-1),uTrackHistory((1:end-1),2));title('v (m/s)');grid on;
    subplot(3,2,3)
    plot(tTrackHistory,xTrackHistory(:,1));title('x (m)');grid on;
    subplot(3,2,4)
    plot(tTrackHistory,xTrackHistory(:,2));title('y (m)');grid on;
    subplot(3,2,5)
    plot(tTrackHistory,xTrackHistory(:,3));title('\theta (rad)');grid on;
    subplot(3,2,6)
    plot(tTrackHistory,xTrackHistory(:,4));title('\beta (rad)');grid on;
end


function animateTractorTrailer(ax, tOut, qOut, alpha, params)
%animateTractorTrailer Playback truck-trailer motions

tSample = tOut;
x2Sample = qOut(:,1);
y2Sample = qOut(:,2);
th2Sample = qOut(:,3);
betaSample = qOut(:,4);
alphaSample = alpha;

W1 = params.W1;
L1 = params.L1;
T0Truck = [1 0 L1/2;
    0 1 0;
    0 0 1];
truckPoints = transformPoints(getRectangleVertices(L1, W1), T0Truck);

W2 = params.W2;
L2 = params.L2;
T0Trailer = [1 0 L2/2;
    0 1 0;
    0 0 1];
trailerPoints = transformPoints(getRectangleVertices(L2, W2), T0Trailer);

W3 = params.Wwheel;
L3 = params.Lwheel;
wheelPoints = getRectangleVertices(L3, W3);

hold on;
hTruck = plot(ax, truckPoints(:,1), truckPoints(:,2), 'color', [1 0.5 0], 'LineWidth', 1, 'Visible', 'off');
hTrailer = plot(ax, truckPoints(:,1), truckPoints(:,2), 'm', 'LineWidth', 1, 'Visible', 'off');
hWheelFL = fill(ax, wheelPoints(:,1), wheelPoints(:,2), 'k', 'Visible', 'off');
hWheelFR = fill(ax, wheelPoints(:,1), wheelPoints(:,2), 'k', 'Visible', 'off');
hWheelRL = fill(ax, wheelPoints(:,1), wheelPoints(:,2), 'k', 'Visible', 'off');
hWheelRR = fill(ax, wheelPoints(:,1), wheelPoints(:,2), 'k', 'Visible', 'off');
hWheelTL = fill(ax, wheelPoints(:,1), wheelPoints(:,2), 'k', 'Visible', 'off');
hWheelTR = fill(ax, wheelPoints(:,1), wheelPoints(:,2), 'k', 'Visible', 'off');
hHinge = plot(ax, [0,0],[0.1 0.1], 'b-', 'LineWidth', 2, 'Visible', 'off');

for i = 1:length(tSample)

    x2 = x2Sample(i);
    y2 = y2Sample(i);
    th2 = th2Sample(i);
    alpha = alphaSample(i);
    qPartial = [x2; y2; th2; betaSample(i)];
    qFull = expandToFullState(qPartial, params);

    x1 = qFull(1); y1 = qFull(2); th1 = qFull(3);

    % Draw Truck
    TTruck = [cos(th1) -sin(th1) x1;
        sin(th1) cos(th1) y1;
        0 0 1];
    pts = transformPoints(truckPoints, TTruck);
    hTruck.XData = pts(:,1);
    hTruck.YData = pts(:,2);

    % Draw Trailer
    TTrailer = [cos(th2) -sin(th2) x2;
        sin(th2) cos(th2) y2;
        0 0 1];
    pts = transformPoints(trailerPoints, TTrailer);
    hTrailer.XData = pts(:,1);
    hTrailer.YData = pts(:,2);

    % Draw truck wheels
    TWheel = [cos(alpha) -sin(alpha) 0;
        sin(alpha) cos(alpha)  0;
        0 0 1];
    TOffsetFL = [1 0 L1; 0 1 W1/2; 0 0 1];
    TOffsetFR = [1 0 L1; 0 1 -W1/2; 0 0 1];
    TOffsetRL = [1 0 0; 0 1 W1/2; 0 0 1];
    TOffsetRR = [1 0 0; 0 1 -W1/2; 0 0 1];
    pts = transformPoints(wheelPoints, TTruck*TOffsetFL*TWheel);
    hWheelFL.XData = pts(:,1);
    hWheelFL.YData = pts(:,2);
    pts = transformPoints(wheelPoints, TTruck*TOffsetFR*TWheel);
    hWheelFR.XData = pts(:,1);
    hWheelFR.YData = pts(:,2);

    pts = transformPoints(wheelPoints, TTruck*TOffsetRL);
    hWheelRL.XData = pts(:,1);
    hWheelRL.YData = pts(:,2);
    pts = transformPoints(wheelPoints, TTruck*TOffsetRR);
    hWheelRR.XData = pts(:,1);
    hWheelRR.YData = pts(:,2);

    % Draw trailer wheels
    TOffsetTL = [1 0 0; 0 1 W2/2; 0 0 1];
    TOffsetTR = [1 0 0; 0 1 -W2/2; 0 0 1];
    pts = transformPoints(wheelPoints, TTrailer*TOffsetTL);
    hWheelTL.XData = pts(:,1);
    hWheelTL.YData = pts(:,2);
    pts = transformPoints(wheelPoints, TTrailer*TOffsetTR);
    hWheelTR.XData = pts(:,1);
    hWheelTR.YData = pts(:,2);

    % Draw Hinge
    pts = [0 0; -params.M, 0];
    pts = transformPoints(pts, TTruck);
    hHinge.XData = pts(:,1);
    hHinge.YData = pts(:,2);

    hTruck.Visible = 'on';
    hTrailer.Visible = 'on';
    hWheelFL.Visible = 'on';
    hWheelFR.Visible = 'on';
    hWheelRL.Visible = 'on';
    hWheelRR.Visible = 'on';
    hWheelTL.Visible = 'on';
    hWheelTR.Visible = 'on';
    hHinge.Visible = 'on';

    % pause for animation
    %drawnow;
    pause(0.3)

end

function points = getRectangleVertices(L, W)
%getRectangleVertices L - along x, W - along y
points = [L/2, W/2;
    L/2, -W/2;
    -L/2, -W/2;
    -L/2, W/2;
    L/2, W/2];

function newPoints = transformPoints(points, T)
%TRANSFORMPOINTS
newPoints = T*[points';ones(1, size(points,1))];
newPoints = newPoints';
newPoints = newPoints(:, 1:2);

function qFull = expandToFullState(qPartial, params)
%EXPANDTOFULLSTATE Computes full truck-trailer state from the partial state
%   [x2, y2, theta2, beta] (rear axle center position, trail heading and
%   the angle between truck and trailer), along with the kinematic params
%   qPartial is 4xn where n is the number of different states being
%   expanded

% Extract cabin/trailer params
L1 = params.L1;
M = params.M;
L2 = params.L2;

% Extract state of trailer's rear axle
x2 = qPartial(1,:);
y2 = qPartial(2,:);
theta2 = qPartial(3,:);
beta = qPartial(4,:);

% Derive state of cabin rear axle
theta1 = theta2 + beta;
x1 = x2 + M .* cos(theta1) + L2 .* cos(theta2);
y1 = y2 + M .* sin(theta1) + L2 .* sin(theta2);

% Package full state, [bodyState(:); trailerState(:)]xN)
qFull = [x1; y1; theta1; x2; y2; theta2; beta];


