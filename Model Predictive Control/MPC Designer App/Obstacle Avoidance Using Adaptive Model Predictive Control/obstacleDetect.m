function detection = obstacleDetect(x,obstacle,laneWidth)
% Detect when the vehicle sees an obstacle.
%#codegen
egoX = x(1);
egoY = x(2);
dist2Obstacle   = sqrt( (obstacle.X - egoX)^2 + (obstacle.Y - egoY)^2 );
flagCloseEnough = (dist2Obstacle < obstacle.DetectionDistance);
flagInLane      = ( abs(obstacle.Y - egoY) < 2*laneWidth );
detection = ( flagCloseEnough && (egoX < obstacle.frSafeX) && flagInLane );