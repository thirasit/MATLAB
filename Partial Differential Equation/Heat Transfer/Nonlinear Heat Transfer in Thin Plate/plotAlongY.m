function plotAlongY( p, u, xVal)
%plotAlongY Create a plot of u along a line of nodes at a specific x value

%       Copyright 2011-2012 The MathWorks, Inc.

nodesAlongY=abs(p(1,:)-xVal) < 1.0e-5;
[xValues,ind]=sort(p(2,nodesAlongY));
uAlongY=u(nodesAlongY);
uAlongY=uAlongY(ind);
figure;
plot(xValues, uAlongY);
grid;
end

