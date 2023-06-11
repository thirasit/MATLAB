function helperOpenFcn
isStopped = strcmp(get_param(bdroot,'SimulationStatus'),'stopped');
if ~isStopped
    h = get_param(gcb,'UserData');
    set(h,'Visible','on');
end
end