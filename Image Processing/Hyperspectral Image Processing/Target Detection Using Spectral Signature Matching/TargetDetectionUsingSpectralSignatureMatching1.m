%%% Target Detection Using Spectral Signature Matching
% This example shows how to detect a known target in the hyperspectral image by using spectral matching method. 
% The pure spectral signature of the known target material is used to detect and locate the target in a hyperspectral image. 
% In this example, you will use the spectral angle mapper (SAM) spectral matching method to detect man-made roofing materials (known target) in a hyperspectral image. 
% The pure spectral signature of the roofing material is read from the ECOSTRESS spectral library and is used as the reference spectrum for spectral matching. 
% The spectral signatures of all the pixels in the data cube are compared with the reference spectrum and the best matching pixel spectrum is classified as belonging to the target material.

% This example requires the Image Processing Toolbox™ Hyperspectral Imaging Library. 
% You can install the Image Processing Toolbox Hyperspectral Imaging Library from Add-On Explorer. 
% For more information about installing add-ons, see Get and Manage Add-Ons. 
% The Image Processing Toolbox Hyperspectral Imaging Library requires desktop MATLAB®, as MATLAB® Online™ and MATLAB® Mobile™ do not support the library.

% This example uses the data sample taken from the Pavia University dataset as the test data. 
% The dataset contains endmember signatures for 9 groundtruth classes and each signature is a vector of length 103. 
% The ground truth classes include Asphalt, Meadows, Gravel, Trees, Painted metal sheets, Bare soil, Bitumen, Self blocking bricks, and Shadows. 
% Of these classes, the painted metal sheets typically belongs to the roofing materials type and it is the desired target to be located.

%%% Read Test Data
% Read the test data from Pavia University dataset by using the hypercube function. 
% The function returns a hypercube object that stores the data cube and the metadata information read from the test data. 
% The test data has 103 spectral bands and their wavelengths range from 430 nm to 860 nm. 
% The geometric resolution is 1.3 meters and the spatial resolution of each band image is 610-by-340.
hcube = hypercube('paviaU.hdr');

% Estimate an RGB color image from the data cube by using the colorize function. 
% Set the ContrastStretching parameter value to true in order to improve the contrast of RGB color image. 
% Display the RGB image.
rgbImg = colorize(hcube,'Method','rgb','ContrastStretching',true);
figure
imshow(rgbImg)
title('RGB Image')

%%% Read Reference Spectrum
% Read the spectral information corresponding to a roofing material from the ECOSTRESS spectral library by using the readEcostressSig function. 
% Add the full file path containing the ECOSTRESS spectral file and read the spectral signature for roofing material from the specified location.
fileroot = matlabshared.supportpkg.getSupportPackageRoot();
addpath(fullfile(fileroot,'toolbox','images','supportpackages','hyperspectral','hyperdata','ECOSTRESSSpectraFiles'));
lib = readEcostressSig("manmade.roofingmaterial.metal.solid.all.0692uuucop.jhu.becknic.spectrum.txt");

% Inspect the properties of the reference spectrum read from the ECOSTRESS library. 
% The output structure lib stores the metadata and the data values read from the ECOSTRESS library.
lib

% Read the wavelength and the reflectance values stored in lib. 
% The wavelength and the reflectance pair comprises the reference spectrum or the reference spectral signature.
wavelength = lib.Wavelength;
reflectance = lib.Reflectance;

% Plot the reference spectrum read from the ECOSTRESS library.
plot(wavelength,reflectance,'LineWidth',2)
axis tight
xlabel('Wavelength (\mum)')
ylabel('Reflectance (%)')
title('Reference Spectrum')

%%% Perform Spectral Matching
% Find the spectral similarity between the reference spectrum and the data cube by using the spectralMatch function. 
% By default, the function uses the spectral angle mapper (SAM) method for finding the spectral match. 
% The output is a score map that signifies the matching between each pixel spectrum and the reference spectrum. 
% Thus, the score map is a matrix of spatial dimension same as that of the test data. 
% In this case, the size of the score map is 610-by-340. 
% SAM is insensitive to gain factors and hence, can be used to match pixel spectrum that inherently have an unknown gain factor due to topographic illumination effects.
scoreMap = spectralMatch(lib,hcube);

% Display the score map.
figure('Position',[0 0 500 600])
imagesc(scoreMap)
colormap parula
colorbar
title('Score Map')

%%% Classify and Detect Target
% Typical values for the SAM score lies in the range [0, 3.142] and the measurement unit is radians. 
% Lower value of SAM score represents better matching between the pixel spectrum and the reference spectrum. 
% Use thresholding method to spatially localize the target region in the input data. 
% To determine the threshold, inspect the histogram of the score map. 
% The minimum SAM score value with prominent number of occurrences can be used to select the threshold for detecting the target region.
figure
imhist(scoreMap);
title('Histogram Plot of Score Map');
xlabel('Score Map Values')
ylabel('Number of occurrences');

% From the histogram plot, you can infer the minimum score value with prominent number of occurrence as approximately 0.22. 
% Accordingly, you can set a value around the local maxima as the threshold. 
% For this example, you can select the threshold for detecting the target as 0.25. 
% The pixel values that are less than the maximum threshold are classified as the target region.
maxthreshold = 0.25;

% Perform thresholding to detect the target region with maximum spectral similarity. 
% Overlay the thresholded image on the RGB image of the hyperspectral data.
thresholdedImg = scoreMap <= maxthreshold;
overlaidImg = imoverlay(rgbImg,thresholdedImg,'green');

% Display the results.
fig = figure('Position',[0 0 900 500]);
axes1 = axes('Parent',fig,'Position',[0.04 0.11 0.4 0.82]);
imagesc(thresholdedImg,'Parent',axes1);
colormap([0 0 0;1 1 1]);
title('Detected Target Region')
axis off
axes2 = axes('Parent',fig,'Position',[0.47 0.11 0.4 0.82]);
imagesc(overlaidImg,'Parent',axes2)
axis off
title('Overlaid Detection Results')

%%% Validate Detection Results
% You can validate the obtained target detection results by using the ground truth data taken from Pavia University dataset.

% Load .mat file containing the ground truth data. 
% To validate the result quantitatively, compute the mean squared error between the ground truth and the output. 
% The error value is less if the obtained results are close to the ground truth.
load('paviauRoofingGT.mat');
err = immse(im2double(paviauRoofingGT), im2double(thresholdedImg));
fprintf('\n The mean squared error is %0.4f\n', err)

fig = figure('Position',[0 0 900 500]);
axes1 = axes('Parent',fig,'Position',[0.04 0.11 0.4 0.82]);
imagesc(thresholdedImg,'Parent',axes1);
colormap([0 0 0;1 1 1]);
title('Result Obtained')
axis off
axes2 = axes('Parent',fig,'Position',[0.47 0.11 0.4 0.82]);
imagesc(paviauRoofingGT,'Parent',axes2)
colormap([0 0 0;1 1 1]);
axis off
title('Ground Truth')
