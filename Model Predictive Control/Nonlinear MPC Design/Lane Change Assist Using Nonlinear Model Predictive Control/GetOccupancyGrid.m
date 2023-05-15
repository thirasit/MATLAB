classdef GetOccupancyGrid < matlab.System
% This object shows status of MIOs surrounding ego car and used by the
% "Visualization" block. The ego car performs the lane change maneuver
% based on the reference from Astar planner.
%
%   This object is a helper for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019 The MathWorks, Inc.
   
    properties(Access = private)
        % Visualization properties 
        Figure
        Figure1
        imH
        BEP
        OutlinePlotter
        LaneBoundaryPlotter
        RefPath
        ColorRed   = [1 0 0];
        ColorGreen = [0 1 0];
        ColorBlue  = [0 0.447 0.741];
        ColorGray  = [0.5 0.5 0.5];
        
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
        % Image parameters
        GridX
        GridY     
        CenterY
        % Driving scenario parameters 
        LaneWidth
        LaneCenters
        scenario
        egoVehicle
    end
    
    methods(Access = protected)
        function setupImpl(obj)
            %% Extracting scenario information for visualization
            scName = evalin('base', 'scenarioFcnName');
            scName = str2func(scName);
            [obj.scenario, obj.egoVehicle]  = scName();
            % Bird's Eye plot for visualizing Lane Change
            figureName = 'Lane Change Status Plot';
            obj.Figure = findobj('Type','Figure','Name',figureName);
            if isempty(obj.Figure)
                % reuse existing figure
                obj.Figure = figure('Name',figureName);
                scrsz = double(get(groot,'ScreenSize'));
                obj.Figure.Position = [100 35 scrsz(3)/4 scrsz(4)*0.865];
            end
            clf(obj.Figure);
            hax = axes(obj.Figure);
            title(hax,'World Coordinates');    
            % create birds eye plot
            obj.BEP = birdsEyePlot('Parent', hax,...
                'XLimits', [0, 300],...%'XLimits', [-60, 60],...
                'YLimits', [-20, 20]);
            figure(obj.Figure);
            % create lane plotter
            obj.LaneBoundaryPlotter = laneBoundaryPlotter(obj.BEP,'DisplayName','Lane boundaries');              
            obj.RefPath = line(hax, 0, 0,...
                'Color',[0 0.447 0.741],...    % aqua   
                'LineWidth',0.1,...
                'LineStyle','-',...                
                'MarkerEdgeColor',[0 0.447 0.741], ...
                'MarkerFaceColor','none', ...
                'Marker','x', ...
                'MarkerSize',3);
            set(obj.RefPath,'XData',[],'YData',[]);
            % create outline plotter for target actors
            obj.OutlinePlotter = outlinePlotter(obj.BEP);
            % disable legend
            legend(obj.BEP.Parent,'off');
       
            %% Occupancy Grid Visualization
            % Image Parameters 
            obj.XRes = 0.5; % p.XResolution;
            obj.YRes = 0.5; % p.YResolution;
            obj.Height = 2 * ceil(200/obj.XRes); %ceil(p.XLength / obj.XRes);
            obj.Width = 2 * ceil(20/obj.YRes); %ceil(p.YLength / obj.YRes);
            obj.CenterY = floor(obj.Width/2);
            h = obj.Height;
            w = obj.Width;
            
            figureName = 'Occupancy Grid';
            obj.Figure1 = findobj('Type','Figure','Name',figureName);
            if isempty(obj.Figure1)
                % reuse existing figure
                obj.Figure1 = figure('Name',figureName);
                scrsz = double(get(groot,'ScreenSize'));
                obj.Figure1.Position = [600 35 scrsz(3)/3 scrsz(4)*2];
            end
            clf(obj.Figure1);
            hax1 = axes(obj.Figure1);
            obj.imH = imshow(zeros(h, w, 1),'Parent', hax1,'Border','loose');
            title(hax1,'Ego Perspective');
            figure(obj.Figure1)
        end
        
        function stepImpl(obj,actors,egoActor,grid,refPath)  
            % Advance driving scenario to extract actor information in World Coordinates
            advance(obj.scenario);
            rbs = roadBoundaries(obj.scenario);
            plotLaneBoundary(obj.LaneBoundaryPlotter,rbs);
            % Number of actors must remain the same between steps
            numActors = actors.NumActors;
            % Extract Ego Car and other actor information
            positions(1,:)= [egoActor.Position(1), egoActor.Position(2)];
%             for n = 2:numActors+1
%                 positions(n,:) = actors.Actors(n-1).Position(1:2);
%                 yaws(n,:)      = actors.Actors(n-1).Yaw;
%             end
            for i = 2:numel(obj.scenario.Actors)
                positions(i,:) = obj.scenario.Actors(i).Position(1:2);
                yaws(i,:) = obj.scenario.Actors(i).Yaw;
            end
            lengths   = ones(numActors+1,1) * obj.CarLength;
            widths    = ones(numActors+1,1) * obj.CarWidth;
            originOffsets = ones(numActors+1,1) * obj.OriginOffset;
            % Plot all the actors in BEP
            plotOutline(obj.OutlinePlotter,...
                positions, yaws, lengths, widths,...
                'OriginOffset',originOffsets);     
            
              % Plot planned path in Occupancy grid
              if(~isempty(refPath))
                  for i=1:size(refPath,1)
                      grid(refPath(i,1),refPath(i,2)) = 1;
                  end
              end
              obj.imH.CData = grid;
              % Plot planned path in BEP
              set(obj.RefPath,'XData',[],'YData',[]);
              set(obj.RefPath,'XData',-((refPath(:,1)' - 800 -egoActor.Position(1)/obj.XRes)*obj.XRes),'YData',-((refPath(:,2)'- obj.CenterY)*obj.YRes)); 
        end

        function val = isInputSizeMutableImpl(~,~)
            val = true;
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