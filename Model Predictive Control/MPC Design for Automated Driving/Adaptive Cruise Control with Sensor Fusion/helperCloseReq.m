function helperCloseReq(fig,event)
%helperCloseReq Captures and executes the 'Close' button click event.
%   In helperBirdsEyePlot, the figure becomes invisible. It will be deleted
%   when the model is closed.

% Make sure the even is to 'close'
if strcmp(event.EventName,'Close')
    if strcmp(fig.HandleVisibility,'off') % Locked against deletion
        set(fig,'Visible','off')
    else
        closereq
    end
end