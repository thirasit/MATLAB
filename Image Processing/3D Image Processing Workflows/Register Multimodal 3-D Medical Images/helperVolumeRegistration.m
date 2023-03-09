function hFig = helperVolumeRegistration(fixedVolume,movingVolume)
%helperVolumeRegistration Simple 3-D registration slice plane visualization.
%  HFIG = helperVisRegistration(FIXEDVOLUME,MOVINGVOLUME) displays a 3-D
%  slice plane visualization of the volumetric image datasets FIXEDVOLUME
%  and MOVINGVOLUME. For each volume, three slices are displayed through
%  the center of the volume along the axial, coronal, and sagittal planes.
%  The view of the axes are linked so that the view of both axes will
%  remain in sync during rotation. The output HFIG is an HG figure handle.

%  Notes
%  -----
%  This is a helper function in support of examples and may change in a
%  future release.

% Copyright 2012 The MathWorks, Inc.

hFig = figure;

hPanelLeft      = uipanel('Parent',hFig,'Position',[0, 0, 0.5, 1]);
hAxLeft         = axes('Parent',hPanelLeft);

hPanelRight     = uipanel('Parent',hFig,'Position',[0.5, 0, 0.5, 1]);
hAxRight        = axes('Parent',hPanelRight);

% Create 3-slice plane view through center of fixedVolume
centerFixed = size(fixedVolume)/2;
slice(hAxLeft,double(fixedVolume),centerFixed(2),centerFixed(1),centerFixed(3));
shading(hAxLeft,'interp');
set(hAxLeft,'Xgrid','on','YGrid','on','ZGrid','on');
set(hFig,'Colormap',colormap('gray'));

% Create 3-slice plane view through center of movingVolume
centerMoving = size(movingVolume)/2;
slice(hAxRight,double(movingVolume),centerMoving(2),centerMoving(1),centerMoving(3));
shading(hAxRight,'interp');
set(hAxRight,'Xgrid','on','YGrid','on','ZGrid','on');

% Link views so that rotation of view will remain in sync across both axes
hLink = linkprop([hAxLeft,hAxRight],'View');
setappdata(hFig,'viewLinkData',hLink);

% Disable interactive zoom and pan
zoomOutButton = findall(hFig,'Tag','Exploration.ZoomOut'); 
zoomInButton  = findall(hFig,'Tag','Exploration.ZoomIn');
panButton     = findall(hFig,'Tag','Exploration.Pan');
set([zoomOutButton,zoomInButton,panButton],'enable','off');
rotate3d(hFig,'on');