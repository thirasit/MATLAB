classdef LanderVehicleAnimation < handle
    
    % Copyright 2023 The MathWorks, Inc.
    
    properties (Access = protected)
        Figure
        FigureName
        NumStates
        NumActions
        Axes
    end
    
    properties (Access = private)
        EnvUpdatedListener
        EnvDeletedListener
        FigDeletedListener
    end
    
    methods
        
        function this = LanderVehicleAnimation(numstates,numactions)
            
            % Parse the remaining inputs
            p = inputParser;
            p.CaseSensitive = false;
            validScalarVal = @(x) isnumeric(x) && isscalar(x) && (x > 0) && mod(x,2)==0;
            validName = @(x)validateattributes(x,{'char'},{'nonempty'});
            addRequired(p,'numstates',validScalarVal);
            addRequired(p,'numactions',validScalarVal);
            addParameter(p,'FigureName','Lander Vehicle',validName);
            parse(p,numstates,numactions);
            this.NumStates = p.Results.numstates;
            this.NumActions = p.Results.numactions;
            this.FigureName = p.Results.FigureName;
            
            % Plot the figure
            plot(this)
        end
        
        function delete(this)
            delete(this.EnvUpdatedListener);
            delete(this.EnvDeletedListener);
            if isvalid(this.Figure)
                this.Figure.CloseRequestFcn = [];
                delete(this.Figure);
            end
        end
        
        function plot(this)
            if isempty(this.Figure) || ~isvalid(this.Figure)
                buildFigure(this);
            end
        end
        
        function bringToFront(this)
            figure(this.Figure);
        end
        
        function updatePlot(this,TimeCount,state,action)
            
            % Get axes
            if isvalid(this)
                ha = this.Axes;
            else
                return
            end
            
            % extract parameters
            L1 = 10;
            L2 = 5;
            l_ = L2*0.5;
            x = state(1);
            y = state(2);
            t = state(3);
            dx = state(4);
            dy = state(5);

            collision = (y - L1) <= 0;
            roughCollision = collision && (dy < -0.5 || abs(dx) > 0.5);
            if collision
                y = L1;
            end

            c = cos(t); s = sin(t);
            R = [c,-s;s,c];

            bodyplot = findobj(ha,'Tag','bodyplot');
            groundplot = findobj(ha,'Tag','groundplot'); %#ok<NASGU>
            ltthrusterbaseplot = findobj(ha,'Tag','ltthrusterbaseplot');
            rtthrusterbaseplot = findobj(ha,'Tag','rtthrusterbaseplot');
            ltthrusterplot = findobj(ha,'Tag','ltthrusterplot');
            rtthrusterplot = findobj(ha,'Tag','rtthrusterplot');
            textplot = findobj(ha,'Tag','textplot');

            if isempty(bodyplot) || ~isvalid(bodyplot) || ...
                    isempty(ltthrusterbaseplot) || ~isvalid(ltthrusterbaseplot) || ...
                    isempty(rtthrusterbaseplot) || ~isvalid(rtthrusterbaseplot) || ...
                    isempty(ltthrusterplot) || ~isvalid(ltthrusterplot) || ...
                    isempty(rtthrusterplot) || ~isvalid(rtthrusterplot) || ...
                    isempty(textplot) || ~isvalid(textplot)

                bodyplot = rectangle(ha,'Position',[x-L1 y-L1 2*L1 2*L1],...
                    'Curvature',[1 1],'FaceColor','y','Tag','bodyplot');
                oceanplot = rectangle(ha,'Position',[-100 -10 200 10],...
                    'FaceColor','c','EdgeColor','c','Tag','oceanplot'); %#ok<NASGU>
                groundplot = line(ha,[-20 20],[0 0],'LineWidth',2,'Color','k','Tag','groundplot'); %#ok<NASGU>
                ltthrusterbaseplot = line(ha,[0 0],[0 0],'LineWidth',1,'Color','k','Tag','ltthrusterbaseplot');
                rtthrusterbaseplot = line(ha,[0 0],[0 0],'LineWidth',1,'Color','k','Tag','rtthrusterbaseplot');

                ltthrusterplot = patch(ha,[0 0 0],[0 0 0],'r','Tag','ltthrusterplot');
                rtthrusterplot = patch(ha,[0 0 0],[0 0 0],'r','Tag','rtthrusterplot');

                textplot = text(ha,0,0,'','Color','r','Tag','textplot');
            end
            
            bodyplot.Position = [x-L1 y-L1 2*L1 2*L1];

            LL1 = [-L2-l_;0];
            LL2 = [-L2+l_;0];
            LR1 = [+L2-l_;0];
            LR2 = [+L2+l_;0];

            TL1 = [-L2-l_;0];
            TL2 = [-L2+l_;0];
            TL3 = [-L2   ;-action(1)];
            TR1 = [+L2-l_;0];
            TR2 = [+L2+l_;0];
            TR3 = [+L2   ;-action(2)];

            in = [LL1 LL2 LR1 LR2 TL1 TL2 TL3 TR1 TR2 TR3];
            out = R*in + [x;y];

            ltthrusterbaseplot.XData = out(1,1:2);
            ltthrusterbaseplot.YData = out(2,1:2);
            rtthrusterbaseplot.XData = out(1,3:4);
            rtthrusterbaseplot.YData = out(2,3:4);

            ltthrusterplot.XData = out(1,5:7 );
            ltthrusterplot.YData = out(2,5:7 );
            rtthrusterplot.XData = out(1,8:10);
            rtthrusterplot.YData = out(2,8:10);

            if roughCollision
                textplot.String = 'Ouch!!!';
                textplot.Position = [x,-5];
            else
                textplot.String = '';
            end

            % Draw time elapsed
            str = sprintf('Time = %0.2fs',TimeCount);
            timestr = findobj(ha,'Tag','timestr');
            if isempty(timestr)
                text(ha,60,110,str,'Tag','timestr');
            else
                timestr.String = str;
            end
            ha.XLim = [-100 100];
            ha.YLim = [-10 120];
            
            % Refresh rendering in figure window
            drawnow();
        end    
        
    end
    
    methods (Access = protected)
        
        function f = buildFigure(this)
            f = figure(...
                'Toolbar','none',...
                'Visible','on',...
                'HandleVisibility','off', ...
                'NumberTitle','off',...
                'Name',this.FigureName,...
                'MenuBar','none',...
                'CloseRequestFcn',@(~,~)delete(this));
            this.Figure = f;
            
            % Default figure size
            width = 800;
            height = 500;
            
            if ~strcmp(f.WindowStyle,'docked')
                f.Position = [100 100 width height];
            end

            ax = axes(f,'NextPlot','add');
            
            % Store axis handle
            this.Axes = ax;
        end
        
    end
    
    methods (Hidden)
        function f = qeGetFigure(this)
            f = this.Figure;
        end
    end
    
    methods (Access = private)
        function envUpdatedCB(this,~,~)
            plot(this);
        end
    end
end

