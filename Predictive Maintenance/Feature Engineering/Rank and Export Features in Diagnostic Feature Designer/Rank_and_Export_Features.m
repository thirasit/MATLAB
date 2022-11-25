%% Rank and Export Features in Diagnostic Feature Designer

% This example shows how to rank features using several classification ranking techniques, how to compare the results, and how to export features from the app. 
% If you want to follow along with the steps interactively, use the data you imported in Process Data and Explore Features in Diagnostic Feature Designer, and use the feature set from that example. 
% Use Open Session to reload your session data using the file name you provided.

figure
imshow("tut2-open-session.png")

% When you generate features for classification, you seek the features that perform best at distinguishing among different conditions. 
% When you view the histograms, you can get an idea of the relative effectiveness of your features. 
% In this example, you use ranking algorithms to perform this feature comparison more rigorously. 
% Once you choose the features you want to retain, you export these features into the MATLAB® workspace.

%%% Rank Features
% Rank your features using the default T-Test method. 
% Click Rank Features. Select FeatureTable1.

figure
imshow("tut3-rank-features-button.png")

% Your selection brings up a ranked list of features, displayed as both a bar chart and a numerical table.

figure
imshow("tut3-ttest-ranking-without-hover.png")

% The bar chart legend shows that the initial ranking is performed using the T-Test method. 
% The chart is normalized to 1 to facilitate visual comparison, while the table displays unnormalized ranking scores. 
% The highest ranking feature is CrestFactor, which has the same value whether it was computed as a signal feature or a rotating machinery feature.

%%% Choose Alternative Ranking Method
% Each ranking method uses different criteria to perform the ranking. 
% In the Feature Ranking tab, click Supervised Ranking to bring up a menu that summarizes each method. 
% From that menu, select Bhattacharyya.

figure
imshow("tut3-supervised-ranking-dropdown-bhatt.png")

% A Bhattacharyya tab opens with ranking specifications that are standard for all of the methods. 
% Click Apply.

figure
imshow("tut3-ranking-bhatt-tab.png")

% Apply updates the ranking display with the new results, displayed along with the original T-Test results.

figure
imshow("tut3-bhat-no-hover-ttest-ranking.png")

% The Bhattacharyya method yields results that are similar to, but not identical to, the T-Test results. 
% The highest ranking feature is PeakValue from the Signal Statistics set. 
% This feature is fourth in the T-test ranking. 
% The crest factor features are still in the top three.

% The ranking is still sorted by T-Test. Sort instead by Bhattacharyya. 
% Close the Bhattacharyya tab and return to the Feature Ranking tab. 
% Then, select Bhattacharyya in the Sort by list.

figure
imshow("tut3-ranking-bhatt-tab-close.png")

figure
imshow("tut3-sort-by-bhatt-tab.png")

% The ranking table now shows PeakValue at the top.

figure
imshow("tut3-sort-by-bhatt-ranking.png")

%%% Delete Set of Rankings
% You have two sets of rankings. 
% Now, delete the Bhattacharyya results. 
% In the Feature Ranking tab, select Delete Scores > Bhattacharyya.

figure
imshow("tut3-delete-bhatt-ranking-tab.png")

% Bhattacharyya disappears from the ranking results.

figure
imshow("tut3-ttest-final-ranking.png")

%%% Export Features to MATLAB Workspace
% The final step in the Diagnostic Features Designer workflow is to export your features. 
% In the Feature Ranking tab, select Export > Export features to the MATLAB workspace.

figure
imshow("tut3-export-select.png")

% Select the features to export. You can sort the features by any of the rankings you have computed. 
% In this case, only one ranking, T-Test, is available. 
% The app preselects the top five features. Modify this selection. 
% Clear the fifth selection and select the sixth feature using Ctrl-click.

figure
imshow("tut3-export-features-selection.png")

% Your reduced feature table appears in your MATLAB workspace.
