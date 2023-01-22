%%% Generate frequency bands around the characteristic fault frequencies of ball or roller bearings for spectral feature extraction

%% Frequency Bands Using Bearing Specifications
% For this example, consider a bearing with a pitch diameter of 12 cm with eight rolling elements. 
% Each rolling element has a diameter of 2 cm. 
% The outer race remains stationary as the inner race is driven at 25 Hz. 
% The contact angle of the rolling element is 15 degrees.

figure
imshow("FrequencyBandsUsingBearingSpecificationsExample_01.png")

% With the above physical dimensions of the bearing, construct the frequency bands using bearingFaultBands.
FR = 25;
NB = 8;
DB = 2;
DP = 12;
beta = 15;
FB = bearingFaultBands(FR,NB,DB,DP,beta)

% FB is returned as a 4x2 array with default frequency band width of 10
% percent of FR which is 2.5 Hz. The first column in FB contains the values of F−W/2, 
% while the second column contains all the values of F+W/2 for each characteristic defect frequency.

%% Frequency Bands for Roller Bearing
% For this example, consider a micro roller bearing with 11 rollers where each roller is 7.5 mm. 
% The pitch diameter is 34 mm and the contact angle is 0 degrees. Assuming a shaft speed of 1800 rpm, construct frequency bands for the roller bearing. 
% Specify 'Domain' as 'frequency' to obtain the frequency bands FB in the same units as FR
FR = 1800;
NB = 11;
DB = 7.5;
DP = 34;
beta = 0;
[FB1,info1] = bearingFaultBands(FR,NB,DB,DP,beta,'Domain','frequency')

% Now, include the sidebands for the inner race and rolling element defect frequencies using the 'Sidebands' name-value pair.
[FB2,info2] = bearingFaultBands(FR,NB,DB,DP,beta,'Domain','order','Sidebands',0:1)

% You can use the generated fault bands FB to extract spectral metrics using the faultBandMetrics command.

%% Visualize Frequency Bands Around Characteristic Bearing Frequencies
% For this example, consider a damaged bearing with a pitch diameter of 12 cm with eight rolling elements. 
% Each rolling element has a diameter of 2 cm. 
% The outer race remains stationary as the inner race is driven at 25 Hz. 
% The contact angle of the rolling element is 15 degrees.

figure
imshow("VisualizeFrequencyBandsAroundBearin.png")

% With the above physical dimensions of the bearing, visualize the fault frequency bands using bearingFaultBands.
figure
FR = 25;
NB = 8;
DB = 2;
DP = 12;
beta = 15;
bearingFaultBands(FR,NB,DB,DP,beta)

% From the plot, observe the following bearing specific vibration frequencies:
% - Cage defect frequency, Fc at 10.5 Hz.
% - Ball defect frequency, Fb at 73 Hz.
% - Outer race defect frequency, Fo at 83.9 Hz.
% - Inner race defect frequency, Fi at 116.1 Hz.

%% Frequency Bands and Spectral Metrics of Ball Bearing
% For this example, consider a ball bearing with a pitch diameter of 12 cm with 10 rolling elements. 
% Each rolling element has a diameter of 0.5 cm. 
% The outer race remains stationary as the inner race is driven at 25 Hz. 
% The contact angle of the ball is 0 degrees. 
% The dataset bearingData.mat contains power spectral density (PSD) and its respective frequency data for the bearing vibration signal in a table.

% First, construct the bearing frequency bands including the first 3 sidebands using the physical characteristics of the ball bearing.
FR = 25;
NB = 10;
DB = 0.5;
DP = 12;
beta = 0;
FB = bearingFaultBands(FR,NB,DB,DP,beta,'Sidebands',1:3)

% FB is a 14x2 array which includes the primary frequencies and their sidebands.

% Load the PSD data. 
% bearingData.mat contains a table X where PSD is contained in the first column and the frequency grid is in the second column, as cell arrays respectively.
load('bearingData.mat','X')
X

% Compute the spectral metrics using the PSD data in table X and the frequency bands in FB.
spectralMetrics = faultBandMetrics(X,FB)

% spectralMetrics is a 1x43 table with peak amplitude, peak frequency and band power calculated for each frequency range in FB. 
% The last column in spectralMetrics is the total band power, computed across all 14 frequencies in FB.
