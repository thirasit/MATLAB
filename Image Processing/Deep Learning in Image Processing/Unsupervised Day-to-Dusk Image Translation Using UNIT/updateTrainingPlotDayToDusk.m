function updateTrainingPlotDayToDusk(ax,ImageX_A,ImageX_AB,ImageX_B,ImageX_BA)

% Copyright 2020 The MathWorks, Inc.

prepForPlot = @(x) (gather(extractdata(x)) + 1)/2;

imagesc(ax(1), prepForPlot(ImageX_A(:,:,:,1)))
ax(1).Title.String = 'Image from Domain A';

imagesc(ax(2), prepForPlot(ImageX_AB(:,:,:,1)))
ax(2).Title.String = 'Translated to Domain B';

imagesc(ax(3), prepForPlot(ImageX_B(:,:,:,1)))
ax(3).Title.String = 'Image from Domain B';

imagesc(ax(4), prepForPlot(ImageX_BA(:,:,:,1)))
ax(4).Title.String = 'Translated to Domain A';

drawnow();
end