%% Utility Functions
function helperDisplayBoxes(obj,bboxes,labels)
% Display the boxes over the image and point cloud.
    figure
    if ~isa(obj,'pointCloud')
        imshow(obj)
        shape = 'rectangle';
    else
        pcshow(obj.Location);
        shape = 'cuboid';
    end
    showShape(shape,bboxes(labels=='Car',:),...
                  'Color','green','LineWidth',0.5);hold on;
    showShape(shape,bboxes(labels=='Truck',:),...
              'Color','magenta','LineWidth',0.5);
    showShape(shape,bboxes(labels=='Pedestrain',:),...
              'Color','yellow','LineWidth',0.5);
    hold off;
end
