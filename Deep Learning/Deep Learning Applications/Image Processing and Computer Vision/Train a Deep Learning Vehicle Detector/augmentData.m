%%% Supporting Functions
function data = augmentData(data)
% Randomly flip images and bounding boxes horizontally.
tform = randomAffine2d('XReflection',true);
sz = size(data{1},[1 2]);
rout = affineOutputView(sz, tform);
data{1} = imwarp(data{1},tform,'OutputView',rout);

% Sanitize boxes, if needed. This helper function is attached as a
% supporting file. Open the example in MATLAB to open this function.
data{2} = helperSanitizeBoxes(data{2});

% Warp boxes.
data{2} = bboxwarp(data{2},tform,rout);
end

function data = preprocessData(data,targetSize)
% Resize image and bounding boxes to targetSize.
sz = size(data{1},[1 2]);
scale = targetSize(1:2)./sz;
data{1} = imresize(data{1},targetSize(1:2));

% Sanitize boxes, if needed. This helper function is attached as a
% supporting file. Open the example in MATLAB to open this function.
data{2} = helperSanitizeBoxes(data{2});

% Resize boxes.
data{2} = bboxresize(data{2},scale);
end
