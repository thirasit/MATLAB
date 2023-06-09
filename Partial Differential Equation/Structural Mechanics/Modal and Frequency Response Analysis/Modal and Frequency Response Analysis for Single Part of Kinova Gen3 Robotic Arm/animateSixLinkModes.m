function frames = animateSixModes(R)
% Animation parameters
%scale = 0.0005;
%nFrames = 30;
scale = 0.001;
nFrames = 30;
flexibleModes = 1:6;
 
% Create a model for plotting purpose.
deformedModel = createpde('structural','modal-solid');
 
% Undeformed mesh data
nodes = R.Mesh.Nodes;
elements = R.Mesh.Elements;
 
% Construct pseudo time-vector that spans one period of first six flexible
% modes.
omega = R.NaturalFrequencies(1:6);
timePeriod = 2*pi./R.NaturalFrequencies(1:6);
 
h = figure('units','normalized','outerposition',[0 0 1 1]);
% Plot deformed shape of the first six flexible modes and capture frame for
% each pseudo time step.
for n = 1:nFrames
    for modeID = 1:6    % 7:12
        % Construct a modal deformation matrix and its magnitude.
        modalDeformation = [R.ModeShapes.ux(:,flexibleModes(modeID))';
            R.ModeShapes.uy(:,flexibleModes(modeID))';
            R.ModeShapes.uz(:,flexibleModes(modeID))'];
        
        modalDeformationMag = sqrt(modalDeformation(1,:).^2 + ...
            modalDeformation(2,:).^2 + ...
            modalDeformation(3,:).^2);
        
        % Compute nodal locations of deformed mesh.
        pseudoTimeVector = linspace(0,timePeriod(modeID),nFrames);
        nodesDeformed = nodes + scale.*modalDeformation*sin(omega(modeID).*pseudoTimeVector(n));
        
        % Construct a deformed geometric shape using displaced nodes and
        % elements from unreformed mesh data.
        geometryFromMesh(deformedModel,nodesDeformed,elements);
        
        % Plot the deformed mesh with magnitude of mesh as color plot.
        subplot(2,3,modeID)
        %plot(modeID)
        pdeplot3D(deformedModel,'ColorMapData', modalDeformationMag)
        title(sprintf(['Flexible Mode %d\n', ...
            'Frequency = %g Hz'], ...
            modeID,omega(modeID)/2/pi));
        
        
        % Remove axes triad and colorbar for clarity
        colorbar off
        delete(findall(gca,'type','quiver'));

        % Remove deformed geometry to reuse to model for next mode.
        deformedModel.Geometry = [];
    end
    % Capture a frame of six deformed mode for time instant
    frames(n) = getframe(h);
end
end

