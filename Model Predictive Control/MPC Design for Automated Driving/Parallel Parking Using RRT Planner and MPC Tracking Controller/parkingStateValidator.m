classdef parkingStateValidator < nav.StateValidator
%parkingStateValidator configures a custom state validation for RRT star
%planner for parallel parking problem.
    
%   Copyright 2019 The MathWorks, Inc.

    
    properties
        Obstacles
        EgoCar
        ValidationDistance
    end
    
    methods
        function obj = parkingStateValidator(ss)
            %VALIDATOROBSTACLELIST
            
            obj@nav.StateValidator(ss);
                        
            % obstacles
            obj.Obstacles = createObstacles();
            
            % ego car
            obj.EgoCar = collisionBox(4.7, 1.8, 0);
            
            obj.ValidationDistance = 0.1;
        end
        
        %isStateValid Check if state is valid
        function isValid = isStateValid(obj, state)
            
            isValid = true(size(state,1),1);
            for k = 1:size(state,1)
                relPose = [1.4, 0, 0];
                st = robotics.core.internal.SEHelpers.accumulatePoseSE2(state(k,:), relPose);
            
                pos = [st(1), st(2), 0];
                quat = eul2quat([st(3), 0, 0]);

                for i = 1:length(obj.Obstacles)
                    [~,dist] = ...
                    robotics.core.internal.intersect(obj.Obstacles{i}.GeometryInternal, ...
                                                     obj.Obstacles{i}.Position, ...
                                                     obj.Obstacles{i}.Quaternion,...
                                                     obj.EgoCar.GeometryInternal,...
                                                     pos, quat, 1); 
                    if dist<=0.15
                        isValid(k) = false;
                        return;
                    end
                end
            end
        end
        
        %isMotionValid Check if path between states is valid
        function [isValid, lastValid] = isMotionValid(obj, state1, state2) 
             % Verify that state1 is valid
            if ~obj.isStateValid(state1)
                isValid = false;
                lastValid = nan(1,obj.StateSpace.NumStateVariables);
                return
            end

            % Interpolate between state1 and state2 with ValidationDistance
            dist = obj.StateSpace.distance(state1, state2);
            interval = obj.ValidationDistance/dist;
            interpStates = obj.StateSpace.interpolate(state1, state2, [0:interval:1 1]);

            % Check all interpolated states for validity
            interpValid = obj.isStateValid(interpStates);
            
            if nargin == 1
                if any(~interpValid)
                    isValid = false;
                else
                    isValid = true;
                end
            else
                % Find the first invalid index. Note that the maximum non-empty
                % value of firstInvalidIdx can be 2, since we always check
                % state1 and state2 and state1 is already verified above.
                firstInvalidIdx = find(~interpValid, 1);

                if isempty(firstInvalidIdx)
                    % The whole motion is valid
                    isValid = true;
                    lastValid = state2;
                else
                    isValid = false;
                    lastValid = interpStates(firstInvalidIdx-1,:);
                end
            end            
        end
        
        
        %COPY Create deep copy of object
        function copyObj = copy(obj)
            % not used
        end
    end
end

%% local function
function obstacles = createObstacles()
% Obstacles (4 occupied parking lots, road curbside and yellow line)
obsLength = 6.2;
egoLength = 4.7;
egoWidth = 1.8;

obs1 = collisionBox(egoLength,egoWidth,0);
T1 = trvec2tform([-2*obsLength,0, 0]);
obs1.Pose = T1;

obs2 = collisionBox(egoLength,egoWidth,0);
T2 = trvec2tform([-obsLength,0, 0]);
obs2.Pose = T2;

obs3 = collisionBox(egoLength,egoWidth,0);
T3 = trvec2tform([obsLength,0, 0]);
obs3.Pose = T3;

obs4 = collisionBox(egoLength,egoWidth,0);
T4 = trvec2tform([2*obsLength,0, 0]);
obs4.Pose = T4;

obs5 = collisionBox(6*obsLength,0.5,0);
T5 = trvec2tform([0,-1.8, 0]);
obs5.Pose = T5;

obs6 = collisionBox(6*obsLength,0.5,0);
T6 = trvec2tform([0,5.65, 0]);
obs6.Pose = T6;


obstacles = {obs1,obs2,obs3,obs4,obs5,obs6};
end

