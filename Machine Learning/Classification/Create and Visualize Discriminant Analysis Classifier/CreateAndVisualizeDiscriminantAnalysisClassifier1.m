%% Create and Visualize Discriminant Analysis Classifier
% This example shows how to perform linear and quadratic classification of Fisher iris data.
% Load the sample data.
load fisheriris

% The column vector, species, consists of iris flowers of three different species, setosa, versicolor, virginica.
% The double matrix meas consists of four types of measurements on the flowers, the length and width of sepals and petals in centimeters, respectively.
% Use petal length (third column in meas) and petal width (fourth column in meas) measurements.
% Save these as variables PL and PW, respectively.
PL = meas(:,3);
PW = meas(:,4);

% Plot the data, showing the classification, that is, create a scatter plot of the measurements, grouped by species.
figure
h1 = gscatter(PL,PW,species,'krb','ov^',[],'off');
h1(1).LineWidth = 2;
h1(2).LineWidth = 2;
h1(3).LineWidth = 2;
legend('Setosa','Versicolor','Virginica','Location','best')

% Create a linear classifier.
X = [PL,PW];
MdlLinear = fitcdiscr(X,species);

% Retrieve the coefficients for the linear boundary between the second and third classes.
MdlLinear.ClassNames([2 3])

K1 = MdlLinear.Coeffs(2,3).Const;  
L1 = MdlLinear.Coeffs(2,3).Linear;

% Plot the curve that separates the second and third classes.
% K+[x_1  x_2]L=0.
figure
h1 = gscatter(PL,PW,species,'krb','ov^',[],'off');
h1(1).LineWidth = 2;
h1(2).LineWidth = 2;
h1(3).LineWidth = 2;
legend('Setosa','Versicolor','Virginica','Location','best')
hold on
f = @(x1,x2) K1 + L1(1)*x1 + L1(2)*x2;
h2 = fimplicit(f,[.9 7.1 0 2.5]);
h2.Color = 'r';
h2.LineWidth = 2;
h2.DisplayName = 'Boundary between Versicolor & Virginica';

% Retrieve the coefficients for the linear boundary between the first and second classes.
MdlLinear.ClassNames([1 2])

K2 = MdlLinear.Coeffs(1,2).Const;
L2 = MdlLinear.Coeffs(1,2).Linear;

% Plot the curve that separates the first and second classes.
figure
h1 = gscatter(PL,PW,species,'krb','ov^',[],'off');
h1(1).LineWidth = 2;
h1(2).LineWidth = 2;
h1(3).LineWidth = 2;
legend('Setosa','Versicolor','Virginica','Location','best')
hold on
f = @(x1,x2) K1 + L1(1)*x1 + L1(2)*x2;
h2 = fimplicit(f,[.9 7.1 0 2.5]);
h2.Color = 'r';
h2.LineWidth = 2;
h2.DisplayName = 'Boundary between Versicolor & Virginica';
hold on
f1 = @(x1,x2) K2 + L2(1)*x1 + L2(2)*x2;
h3 = fimplicit(f1,[.9 7.1 0 2.5]);
h3.Color = 'k';
h3.LineWidth = 2;
h3.DisplayName = 'Boundary between Versicolor & Setosa';
axis([.9 7.1 0 2.5])
xlabel('Petal Length')
ylabel('Petal Width')
title('{\bf Linear Classification with Fisher Training Data}')

% Create a quadratic discriminant classifier.
MdlQuadratic = fitcdiscr(X,species,'DiscrimType','quadratic');

% Remove the linear boundaries from the plot.
%delete(h2);
%delete(h3);

% Retrieve the coefficients for the quadratic boundary between the second and third classes.
MdlQuadratic.ClassNames([2 3])

K3 = MdlQuadratic.Coeffs(2,3).Const;
L3 = MdlQuadratic.Coeffs(2,3).Linear; 
Q3 = MdlQuadratic.Coeffs(2,3).Quadratic;

% Plot the curve that separates the second and third classes.
figure
imshow("Opera Snapshot_2024-01-19_061711_www.mathworks.com.png")
axis off;

figure
h1 = gscatter(PL,PW,species,'krb','ov^',[],'off');
h1(1).LineWidth = 2;
h1(2).LineWidth = 2;
h1(3).LineWidth = 2;
legend('Setosa','Versicolor','Virginica','Location','best')
hold on
f3 = @(x1,x2) K3 + L3(1)*x1 + L3(2)*x2 + Q3(1,1)*x1.^2 + ...
    (Q3(1,2)+Q3(2,1))*x1.*x2 + Q3(2,2)*x2.^2;
h2 = fimplicit(f3,[.9 7.1 0 2.5]);
h2.Color = 'r';
h2.LineWidth = 2;
h2.DisplayName = 'Boundary between Versicolor & Virginica';
xlabel('Petal Length')
ylabel('Petal Width')
title('{\bf Linear Classification with Fisher Training Data}')

% Retrieve the coefficients for the quadratic boundary between the first and second classes.
MdlQuadratic.ClassNames([1 2])

K4 = MdlQuadratic.Coeffs(1,2).Const;
L4 = MdlQuadratic.Coeffs(1,2).Linear; 
Q4 = MdlQuadratic.Coeffs(1,2).Quadratic;

% Plot the curve that separates the first and second and classes.
figure
h1 = gscatter(PL,PW,species,'krb','ov^',[],'off');
h1(1).LineWidth = 2;
h1(2).LineWidth = 2;
h1(3).LineWidth = 2;
legend('Setosa','Versicolor','Virginica','Location','best')
hold on
f3 = @(x1,x2) K3 + L3(1)*x1 + L3(2)*x2 + Q3(1,1)*x1.^2 + ...
    (Q3(1,2)+Q3(2,1))*x1.*x2 + Q3(2,2)*x2.^2;
h2 = fimplicit(f3,[.9 7.1 0 2.5]);
h2.Color = 'r';
h2.LineWidth = 2;
h2.DisplayName = 'Boundary between Versicolor & Virginica';
hold on
f4 = @(x1,x2) K4 + L4(1)*x1 + L4(2)*x2 + Q4(1,1)*x1.^2 + ...
    (Q4(1,2)+Q4(2,1))*x1.*x2 + Q4(2,2)*x2.^2;
h3 = fimplicit(f4,[.9 7.1 0 1.02]); % Plot the relevant portion of the curve.
h3.Color = 'k';
h3.LineWidth = 2;
h3.DisplayName = 'Boundary between Versicolor & Setosa';
axis([.9 7.1 0 2.5])
xlabel('Petal Length')
ylabel('Petal Width')
title('{\bf Quadratic Classification with Fisher Training Data}')
hold off
