classdef outputgrid < matlab.System
% This object generates a discrete grid that contains information of the
% environment and cars surrounding the Ego vehiclen and used by the
% "Occupancy Grid Generator" block.
%
%   This object is a helper for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019 The MathWorks, Inc.
    
    properties(Access = private)
        CarLength = 4.7;
        CarWidth = 1.8;
        OriginOffset = [-1.35 0]; 
        % Grid resolution in X coordinate (longitudinal)
        XRes 
        % Grid resolution in Y coordinate (lateral)
        YRes       
        % Height of the occupancy grid map
        Height      
        % Width of the occupancy grid map
        Width      
        GridX
        GridY     
        CenterY
        % Driving scenario parameters 
        LaneWidth
        LaneCenters
        lbWorld % lane boundaries in world coordinates
        scenario
        egoVehicle
    end
    
    methods(Access = protected)
        function setupImpl(obj)
            %% Extracting scenario information
            scName = evalin('base', 'scenarioFcnName');
            scName = str2func(scName);
            [obj.scenario, obj.egoVehicle]  = scName();
            lbs = laneBoundaries(obj.egoVehicle,'LocationType','Center','AllBoundaries',true);
            obj.LaneWidth = 3.6; 
            % Converting lane bboundaries from ego coordinates to world coordinates
            for i = 1:size(lbs,1) %numLaneBoundaries
                % considering just the lateral coordinates as longitudinal coordinates does not matter for straight roads
                obj.lbWorld(i) = lbs(i).Coordinates(2) + obj.egoVehicle.Position(2); 
            end
            % Calculate Lane centers 
            obj.LaneCenters = obj.lbWorld(1:size(lbs,1)-1) - obj.LaneWidth/2; % shifting to the right in Vehicle Coordinates
            
            %% Grid parameters
            obj.XRes = 0.5; 
            obj.YRes = 0.5; 
            obj.Height = 2 * ceil(200/obj.XRes); 
            obj.Width = 2 * ceil(20 / obj.YRes); 
            obj.CenterY = floor(obj.Width/2);
            [Yg, Xg] = meshgrid(1:obj.Width, 1:obj.Height);
            % make it 3D for vectorized computation
            obj.GridX = shiftdim(Xg, -1); 
            obj.GridY = shiftdim(Yg, -1); 
        end
        
        function [grid, egoPose, lc] = stepImpl(obj,actors,egoActor,lanes)
            % Advance driving scenario to extract actor information in World Coordinates
            advance(obj.scenario);
            rbs = roadBoundaries(obj.scenario);
            numActors = actors.NumActors;
            positions(1,:) = [egoActor.Position(1),egoActor.Position(2)];          
            for i = 2:numel(obj.scenario.Actors)
               positions(i,:) = obj.scenario.Actors(i).Position(1:2); 
            end           
           
            % Vertices of all the actors have been inflated by CarLength/2 and CarWidth/2 for length and width respectively to serve as collision buffer
            xdata= [positions(1:end,1)-obj.CarLength, positions(1:end,1)+obj.CarLength, positions(1:end,1)+ obj.CarLength, positions(1:end,1)-obj.CarLength];
            ydata  = [positions(1:end,2)- obj.CarWidth, positions(1:end,2)- obj.CarWidth, positions(1:end,2)+ obj.CarWidth, positions(1:end,2)+ obj.CarWidth];
            % No collision buffer for ego car for planning purposes
            xdata(1,:) = [xdata(1,1)+obj.CarLength/2, xdata(1,2)-obj.CarLength/2-1.35, xdata(1,3)-obj.CarLength/2-1.35, xdata(1,4)+obj.CarLength/2];
            ydata(1,:)= [ydata(1,1:2) + obj.CarWidth/2, ydata(1,3:4) - obj.CarWidth/2];
            % Extracting road boundary information in World Coordinates
            rightEdge = -min(rbs{1}(:,2)); % min because of the vehicle coordinates, y is positive towards the left
            leftEdge = -max(rbs{1}(:,2)); % negative sign to take care of the rotation to world coordinates in image
            xdata = [-xdata;
                     -1000, 200, 200, -1000;
                     -1000, 200, 200, -1000];
            ydata = [-ydata;
                     rightEdge, rightEdge, rightEdge+1, rightEdge+1;
                     leftEdge, leftEdge, leftEdge-1, leftEdge-1];
           % Converting to Image Coordinates and in Ego perspective (To see everything ahead of the car)
           xdataIm = xdata/obj.XRes + 800 - (-egoActor.Position(1)/obj.XRes); %xdata(1,1),800 is the obj.Height, -egoActor is to see everything ahead of ego car
           ydataIm = ydata/obj.YRes + 40; 
           [xmin, xmax] = bounds(xdataIm, 2);
           [ymin, ymax] = bounds(ydataIm, 2);
           % Occupancy grid
           grid = double(shiftdim(sum((obj.GridX >= xmin &...    
                  obj.GridX <= xmax &... 
                  obj.GridY >=ymin &...
                  obj.GridY <= ymax), 1))); 
              
           % Current position of the Ego Car
           egoPose = [round((xdataIm(1,2) + xdataIm(1,3))/2), round((ydataIm(1,2) + ydataIm(1,3))/2)]; % average of front corners of the ego car
           %% 
           % Check if the adjacent lane is a valid lane for lane change
           % Initializing variables
           validLanes = [];
           invalidLanes =[];
           removeLane = [];
           k =1;j =1;m =1;
           % Positions of actors in World Coordinates
           positionWorld = positions(2:end,:);
           % Position of actors in Ego Coordinates
           for n = 1:numActors
                positionEgo(n,:) = actors.Actors(n).Position(1:2);
           end
           % Identify cars that are within a range close to the ego car
           % range -35 to 30, -30 to make sure other cars do not sneak up 
           % from the back and 35 because of the planning range of 30m
           % lookahead and tolerances associated with conversion from different coordinates.
           actorsIdx = (positionEgo(:,1)<35 & positionEgo(:,1) > -30);  
           actorsInRange = positionWorld(actorsIdx,:);
           
           % Identify current lane of ego car, valid lanes to which lane
           % change is possible and invalid lanes
           numlanes = lanes.NumLaneBoundaries -1;
           for i = 1:numlanes
               invalidIdx  = actorsInRange(:,2) < obj.lbWorld(i) & actorsInRange(:,2) > obj.lbWorld(i+1);
               currentIdx = egoActor.Position(2)< obj.lbWorld(i) & egoActor.Position(2)> obj.lbWorld(i+1);
               if(currentIdx)
                   currentLane = i;
               end
               if(sum(invalidIdx(:)==1))
                   invalidLanes(k) = i;
                   k=k+1;
               else
                   validLanes(j) = i;
                   j = j+1;
               end
           end
           
           % Adding lane centers of valid lanes as additional goals for
           % planning purposes
           if(~isempty(validLanes))
               % Convert Lane center values to coordinates in the occupancy grid
               lc = -obj.LaneCenters/obj.YRes + obj.CenterY;
               for i = 1:size(validLanes,2)
                   % Identify and removes lanes to which the ego car has to
                   % pass through invalid lane
                   if(~(abs(validLanes(i)-currentLane)<=1))
                       removeLane(m) = i;
                       m = m+1;
                   end
               end
               validLanes(removeLane) = [];
               lc = lc(validLanes);
           else
               lc = [];
           end
        end

        %  Adding propagation methods:
        function [fz1,fz2,fz3] = isOutputFixedSizeImpl(~)
          %Both outputs are always variable-sized
          fz1 = true;
          fz2 = true;
          fz3 = false;
        end
    
        function [sz1,sz2,sz3] = getOutputSizeImpl(obj)
            if (~isempty(propagatedInputSize(obj, 1)))
                sz1 = [800 80]; % Grid size
                sz2 = [1 2]; % Ego Postion 
                sz3 = [1 10]; % Maximum number of lanes
            else
                sz1 = [];
                sz2 = [];
                sz3 = [];
            end
        end
    
        function [dt1, dt2, dt3] = getOutputDataTypeImpl(obj)
            dt1 = 'double'; %Linear indices are always double values
            dt2 = 'double';%propagatedInputDataType(obj, 1);
            dt3 = 'double';
        end

        function [cp1, cp2, cp3] = isOutputComplexImpl(obj)
            cp1 = false; %Linear indices are always real values
            cp2 = propagatedInputComplexity(obj, 1);
            cp3 = false;
        end
    end
     
    methods(Access = protected, Static)
        function simMode = getSimulateUsingImpl
            % Return only allowed simulation mode in System block dialog
            simMode = "Interpreted execution";
        end
        
        function flag = showSimulateUsingImpl
            % Return false if simulation mode hidden in System block dialog
            flag = false;
        end
    end
    
end