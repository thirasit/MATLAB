%% Preprocess Data
function data = preprocessData(data,targetSize,isRotRect)
% Resize the images and scale the pixels to between 0 and 1. Also scale the
% corresponding bounding boxes.
for ii = 1:size(data,1)
    I = data{ii,1};
    imgSize = size(I);
    
    % Convert an input image with a single channel to three channels.
    if numel(imgSize) < 3 
        I = repmat(I,1,1,3);
    end
    bboxes = data{ii,2};

    I = im2single(imresize(I,targetSize(1:2)));
    scale = targetSize(1:2)./imgSize(1:2);
    bboxes = bboxresize(bboxes,scale);

    if ~isRotRect
        bboxes = bboxes(:,1:4);
    end
    
    data(ii, 1:2) = {I,bboxes};
end
end
