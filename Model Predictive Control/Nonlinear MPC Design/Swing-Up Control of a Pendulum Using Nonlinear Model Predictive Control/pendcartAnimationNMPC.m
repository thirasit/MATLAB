function pendcartAnimationNMPC(block, varargin)
%pendcartAnimation Level-2 M S-function for MPC pendulum animation.

%   Copyright 1990-2022 The MathWorks, Inc.

% Plots every major integration step, but has no states of its own
    if nargin == 1
        setup(block);
    else
        switch varargin{end}
            %%%%%%%%%%%%%%%
            % DeleteBlock %
            %%%%%%%%%%%%%%%
            case 'DeleteBlock'
                LocalDeleteBlock
            
            %%%%%%%%%%%%%%%
            % DeleteFigure %
            %%%%%%%%%%%%%%%
            case 'DeleteFigure'
                LocalDeleteFigure
            
            %%%%%%%%%%
            % Slider %
            %%%%%%%%%%
            case 'Slider'
                LocalSlider
            
            %%%%%%%%%
            % Close %
            %%%%%%%%%
            case 'Close'
                LocalClose
            
        end
    end
end

function setup(block)
    % Register parameters
    block.NumDialogPrms = 1; % RefBlock
    
    % Register number of ports
    block.NumInputPorts = 1;
    block.NumOutputPorts = 0;

    % Override input port properties
    block.InputPort(1).DatatypeID = 0;
    block.InputPort(1).Dimensions = 3;
    block.InputPort(1).DirectFeedthrough = true;

    %
    % initialize the array of sample times, for the pendulum example,
    % the animation is updated every 0.1 seconds
    block.SampleTimes = [0.1 0];

    %
    % create the figure, if necessary
    %
    LocalPendInit(block.DialogPrm(1).Data); % RefBlock
    
    %
    % specify that the simState for this s-function is same as the default
    %
    block.SimStateCompliance = 'DefaultSimState';
    block.SetSimViewingDevice(true);% no TLC required
    block.RegBlockMethod('Update', @mdlUpdate);
    block.RegBlockMethod('Terminate', @mdlTerminate);
end


%
%=============================================================================
% mdlUpdate
% Update the pendulum animation.
%=============================================================================
%
function mdlUpdate(block)
    t = block.CurrentTime;
    u = block.InputPort(1).Data;

    fig = get_param(gcbh,'UserData');
    if ishghandle(fig, 'figure')
      if strcmp(get(fig,'Visible'),'on')
        ud = get(fig,'UserData');
        LocalPendSets(t,ud,u);
      end
    end
end

%
%=============================================================================
% mdlTerminate
% Re-enable playback buttong for the pendulum animation.
%=============================================================================
%
function mdlTerminate(~) 

    fig = get_param(gcbh,'UserData');
    if ishghandle(fig, 'figure')
        pushButtonPlayback = findobj(fig,'Tag','penddemoPushButton');
        set(pushButtonPlayback,'Enable','on');
    end
end

%
%=============================================================================
% LocalDeleteBlock
% The animation block is being deleted, delete the associated figure.
%=============================================================================
%
function LocalDeleteBlock

    fig = get_param(gcbh,'UserData');
    if ishghandle(fig, 'figure')
      delete(fig);
      set_param(gcbh,'UserData',-1)
    end
end

%
%=============================================================================
% LocalDeleteFigure
% The animation figure is being deleted, set the S-function UserData to -1.
%=============================================================================
%
function LocalDeleteFigure

    ud = get(gcbf,'UserData');
    set_param(ud.Block,'UserData',-1);
end

%
%=============================================================================
% LocalSlider
% The callback function for the animation window slider uicontrol.  Change
% the reference block's value.
%=============================================================================
%
function LocalSlider

    ud = get(gcbf,'UserData');
    set_param(ud.RefBlock,'Value',num2str(get(gcbo,'Value')));
end

%
%=============================================================================
% LocalClose
% The callback function for the animation window close button.  Delete
% the animation figure window.
%=============================================================================
%
function LocalClose

    delete(gcbf)
end

%
%=============================================================================
% LocalPendSets
% Local function to set the position of the graphics objects in the
% inverted pendulum animation window.
%=============================================================================
%
function LocalPendSets(time,ud,u)

    XDelta   = 2;
    PDelta   = 0.2;
    XPendTop = u(2) + 10*sin(u(3));
    YPendTop = 10*cos(u(3));
    PDcosT   = PDelta*cos(u(3));
    PDsinT   = -PDelta*sin(u(3));
    set(ud.Cart,...
      'XData',ones(2,1)*[u(2)-XDelta u(2)+XDelta]);
    set(ud.Pend,...
      'XData',[XPendTop-PDcosT XPendTop+PDcosT; u(2)-PDcosT u(2)+PDcosT], ...
      'YData',[YPendTop-PDsinT YPendTop+PDsinT; -PDsinT PDsinT]);
    set(ud.TimeField,...
      'String',num2str(time));
    set(ud.RefMark,...
      'XData',u(1)+[-XDelta 0 XDelta]);
    
    % Force plot to be drawn
    pause(0)
    drawnow
end

%
%=============================================================================
% LocalPendInit
% Local function to initialize the pendulum animation.  If the animation
% window already exists, it is brought to the front.  Otherwise, a new
% figure window is created.
%=============================================================================
%
function LocalPendInit(RefBlock)

    %
    % The name of the reference is derived from the name of the
    % subsystem block that owns the pendulum animation S-function block.
    % This subsystem is the current system and is assumed to be the same
    % layer at which the reference block resides.
    %
    sys = get_param(gcs,'Parent');
    
    TimeClock = 0;
    %RefSignal = str2double(get_param([sys '/' RefBlock],'Value'));

    RefSignal = str2double(get_param([sys '/' RefBlock],'Before'));
    Limit = str2double(get_param([sys '/' RefBlock],'After'))*2;
    
    XCart     = 0;
    Theta     = 0;
    
    XDelta    = 2;
    PDelta    = 0.2;
    XPendTop  = XCart + 10*sin(Theta); % Will be zero
    YPendTop  = 10*cos(Theta);         % Will be 10
    PDcosT    = PDelta*cos(Theta);     % Will be 0.2
    PDsinT    = -PDelta*sin(Theta);    % Will be zero
    
    %
    % The animation figure handle is stored in the pendulum block's UserData.
    % If it exists, initialize the reference mark, time, cart, and pendulum
    % positions/strings/etc.
    %
    Fig = get_param(gcbh,'UserData');
    if ishghandle(Fig ,'figure')
      FigUD = get(Fig,'UserData');
      set(FigUD.RefMark,...
          'XData',RefSignal+[-XDelta 0 XDelta]);
      set(FigUD.TimeField,...
          'String',num2str(TimeClock));
      set(FigUD.Cart,...
          'XData',ones(2,1)*[XCart-XDelta XCart+XDelta]);
      set(FigUD.Pend,...
          'XData',[XPendTop-PDcosT XPendTop+PDcosT; XCart-PDcosT XCart+PDcosT],...
          'YData',[YPendTop-PDsinT YPendTop+PDsinT; -PDsinT PDsinT]);

      set(FigUD.AxesH,'Xlim',[-Limit Limit]);      
      
      % disable playback button during simulation
      pushButtonPlayback = findobj(Fig,'Tag','penddemoPushButton');
      set(pushButtonPlayback,'Enable','off');
            
      %
      % bring it to the front
      %
      figure(Fig);
      return
    end
    
    %
    % the animation figure doesn't exist, create a new one and store its
    % handle in the animation block's UserData
    %
    FigureName = 'Pendulum Visualization';
    Fig = figure(...
      'Units',           'pixel',...
      'Position',        [100 100 500 300],...
      'Name',            FigureName,...
      'NumberTitle',     'off',...
      'IntegerHandle',   'off',...
      'HandleVisibility','callback',...
      'Resize',          'off',...
      'DeleteFcn',       'pendcartAnimationNMPC([],[],[],''DeleteFigure'')',...
      'CloseRequestFcn', 'pendcartAnimationNMPC([],[],[],''Close'');');
    AxesH = axes(...
      'Parent',  Fig,...
      'Units',   'pixel',...
      'Position',[50 50 400 200],...
      'CLim',    [1 64], ...
      'Xlim',    [-12 12],...
      'Ylim',    [-2 10],...
      'Visible', 'off');
    Cart = surface(...
      'Parent',   AxesH,...
      'XData',    ones(2,1)*[XCart-XDelta XCart+XDelta],...
      'YData',    [0 0; -2 -2],...
      'ZData',    zeros(2),...
      'CData',    11*ones(2));
    Pend = surface(...
      'Parent',   AxesH,...
      'XData',    [XPendTop-PDcosT XPendTop+PDcosT; XCart-PDcosT XCart+PDcosT],...
      'YData',    [YPendTop-PDsinT YPendTop+PDsinT; -PDsinT PDsinT],...
      'ZData',    zeros(2),...
      'CData',    11*ones(2));
    RefMark = patch(...
      'Parent',   AxesH,...
      'XData',    RefSignal+[-XDelta 0 XDelta],...
      'YData',    [-2 0 -2],...
      'CData',    22,...
      'FaceColor','flat');
    uicontrol(...
      'Parent',  Fig,...
      'Style',   'text',...
      'Units',   'pixel',...
      'Position',[0 0 500 50]);
    uicontrol(...
      'Parent',             Fig,...
      'Style',              'text',...
      'Units',              'pixel',...
      'Position',           [150 0 100 25], ...
      'HorizontalAlignment','right',...
      'String',             'Time: ');
    TimeField = uicontrol(...
      'Parent',             Fig,...
      'Style',              'text',...
      'Units',              'pixel', ...
      'Position',           [250 0 100 25],...
      'HorizontalAlignment','left',...
      'String',             num2str(TimeClock));
    SlideControl = uicontrol(...
      'Parent',   Fig,...
      'Style',    'slider',...
      'Units',    'pixel', ...
      'Position', [100 25 300 22],...
      'Min',      -9,...
      'Max',      9,...
      'Value',    RefSignal,...
      'Callback', 'pendcartAnimationNMPC([],[],[],''Slider'');');
    uicontrol(...
      'Parent',  Fig,...
      'Style',   'pushbutton',...
      'Position',[415 15 70 20],...
      'String',  'Close', ...
      'Callback','pendcartAnimationNMPC([],[],[],''Close'');');
    
    %
    % all the HG objects are created, store them into the Figure's UserData
    %
    FigUD.AxesH        = AxesH;
    FigUD.Cart         = Cart;
    FigUD.Pend         = Pend;
    FigUD.TimeField    = TimeField;
    FigUD.SlideControl = SlideControl;
    FigUD.RefMark      = RefMark;
    FigUD.Block        = get_param(gcbh,'Handle');
    FigUD.RefBlock     = get_param([sys '/' RefBlock],'Handle');
    set(Fig,'UserData',FigUD);
    
    drawnow
    
    %
    % store the figure handle in the animation block's UserData
    %
    set_param(gcbh,'UserData',Fig);
end
