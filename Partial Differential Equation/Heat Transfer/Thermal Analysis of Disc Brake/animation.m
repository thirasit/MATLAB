function M = animation(model, results)

    nframes = numel(results.SolutionTimes);
    delay = 0.01;
    
    for i = 1:nframes
        
        h = pdeplot3D(model, 'ColorMapData', results.Temperature(:, i));
        set(gcf,'units','normalized','outerposition',[0 0 1 1]);
        delete(findall(gca,'type','quiver'));
        qt = findall(gca,'type','text');
        set(qt(1:3),'Visible','off')
        %h(1).Limits = [0, 150];
        view([0, -45]);
        caxis([min(min(results.Temperature)), max(max(results.Temperature))]);
        drawnow;
        pause(delay);
        
        M(i) = getframe(gcf);
        
        
        
    end
    


end

