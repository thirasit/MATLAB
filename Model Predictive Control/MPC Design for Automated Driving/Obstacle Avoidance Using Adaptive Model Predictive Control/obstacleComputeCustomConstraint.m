function [E,F,G,constraintSlope,constraintIntercept] = obstacleComputeCustomConstraint(x,detection,obstacle,laneWidth,lanes)
%% Compute custom constraints for the obstacle.

%#codegen
egoX = x(1);
egoY = x(2);

% Compute constraints only if an obstacle is detected. Otherwsie, set
% constraint to lower road boundary (the inactive constraint).
if detection
    slope = ( (obstacle.rlSafeY - egoY)/(obstacle.rlSafeX - egoX) );
    % If ego car is to the left of the obstacle
    if (egoX<=obstacle.rlSafeX)
        % if the ego car is already in the adjacent lane, use the safety
        % zone as the constraint.
        if (egoY>obstacle.rlSafeY)
            constraintSlope = 0;
            constraintIntercept = obstacle.rlSafeY;
        else
            % The ego car must be above the line formed from the ego car to
            % safe zone corner for left passing.
            constraintSlope = tan(atan2(slope,1));
            constraintIntercept = obstacle.rlSafeY - constraintSlope*obstacle.rlSafeX;
        end
    % If the ego car is parallel to the obstacle, use the safety zone as
    % the constraint.
    elseif ( (egoX>obstacle.rlSafeX) && (egoX<=obstacle.flX) )
        constraintSlope = 0;
        constraintIntercept = obstacle.rlSafeY; 
    % If the ego car has passed the obstacle, use the inactive constraint
    % to go back to the center lane.
    else 
        constraintSlope = 0;
        constraintIntercept = -laneWidth*lanes/2;
    end
else
    constraintSlope = 0;
    constraintIntercept = -laneWidth*lanes/2;
end

%% Define constraint matrices.
E = [0 0;0 0;0 0];
F = [0 1 0 0;0 -1 0 0;constraintSlope -1 0 0]; 
G = [laneWidth*lanes/2;laneWidth*lanes/2;-1*constraintIntercept];
