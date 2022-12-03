function helperPlotConfidenceEllipsoid(M,C,n,color)
%helperPlotConfidenceEllipsoid Plot confidence region for 3D data.
%
% This function is only in support of
% CentrifugalPumpFaultDiagnosisUsingSteadyStateExperimentsExample. It may
% change in a future release.

% Copyright 2017 The MathWorks, Inc.

%Compute the surface points of a N standard deviations ellipsoid
%corresponding to the provided mean (M) and covariance (C) data.
[U,L] = eig(C);

% For n standard deviation spread of data, the radii of the ellipsoid will
% be given by n*SQRT(eigenvalues) 
l = 50;
radii = n*sqrt(diag(L)); 
[xc,yc,zc] = ellipsoid(0,0,0,radii(1),radii(2),radii(3),l);
%
a = kron(U(:,1),xc); b = kron(U(:,2),yc); c = kron(U(:,3),zc);
data = a+b+c; 
nc = size(data,2);
x = data(1:nc,:)+M(1); 
y = data(nc+1:2*nc,:)+M(2); 
z = data(2*nc+1:end,:)+M(3);

if isscalar(color), color = color*ones(1,3); end
ColorMap(:,:,1) = color(1)*ones(l+1);
ColorMap(:,:,2) = color(2)*ones(l+1);
ColorMap(:,:,3) = color(3)*ones(l+1);

sc = surf(x,y,z,ColorMap); 
shading interp
alpha(sc,0.4); 
camlight headlight 
lighting phong

