function helperCloseAll(blk)
% Closes all the bird's-eye plot figures that may have been created when
% the model is closed.
root = groot;
shh = get(root,'ShowHiddenHandles');
set(root,'ShowHiddenHandles','on');
if isempty(get(root,'Children'))
    set(root,'ShowHiddenHandles',shh)
    return
else
    figs = root.Children;
    for i=1:numel(figs)
        tag = figs(i).Tag;
        if strcmp(tag,blk) % Only close the figure that was open for this model
            set(figs(i),'HandleVisibility','on');
            close(figs(i));
        end
    end
    set(root,'ShowHiddenHandles',shh)
end