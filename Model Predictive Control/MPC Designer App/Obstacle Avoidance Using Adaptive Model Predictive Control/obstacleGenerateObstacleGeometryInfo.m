function obstacle = obstacleGenerateObstacleGeometryInfo(obstacle)
% Generate obstacle and safe zone geometry.

%Obstacle:
% Front left
obstacle.flX = obstacle.X+obstacle.Length/2;
obstacle.flY = obstacle.Y+obstacle.Width/2;
% Front right
obstacle.frX = obstacle.X+obstacle.Length/2;
obstacle.frY = obstacle.Y-obstacle.Width/2;
% Rear left
obstacle.rlX = obstacle.X-obstacle.Length/2;
obstacle.rlY = obstacle.flY;
% Rear right
obstacle.rrX = obstacle.X-obstacle.Length/2;
obstacle.rrY = obstacle.frY;

%Safe zone:
% Front left
obstacle.flSafeX = obstacle.X+obstacle.safeDistanceX; 
obstacle.flSafeY = obstacle.Y+obstacle.safeDistanceY;
% Front right
obstacle.frSafeX = obstacle.X+obstacle.safeDistanceX;
obstacle.frSafeY = obstacle.Y-obstacle.safeDistanceY;
% Rear left
obstacle.rlSafeX = obstacle.X-obstacle.safeDistanceX; 
obstacle.rlSafeY = obstacle.flSafeY;
% Rear right
obstacle.rrSafeX = obstacle.X-obstacle.safeDistanceX;
obstacle.rrSafeY = obstacle.frSafeY;
