%%% Supporting Function
% The plotColorAngle function plots a unit vector of an illuminant in 3-D RGB color space.
% The input argument illum specifies the illuminant as an RGB color and the input argument ax specifies the axes on which to plot the unit vector.
function plotColorAngle(illum,ax)
    R = illum(1);
    G = illum(2);
    B = illum(3);
    magRGB = norm(illum);
    plot3([0 R/magRGB],[0 G/magRGB],[0 B/magRGB], ...
        Marker=".",MarkerSize=10,Parent=ax)
    xlabel("R")
    ylabel("G")
    zlabel("B")
    xlim([0 1])
    ylim([0 1])
    zlim([0 1])
end