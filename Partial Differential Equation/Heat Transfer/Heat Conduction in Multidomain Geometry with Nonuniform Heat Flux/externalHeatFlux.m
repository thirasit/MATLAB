function Qflux = externalHeatFlux(region,~)
[phi,theta,~] = cart2sph(region.x,region.y,region.z);
theta = pi/2 - theta; % transform to 0 <= theta <= pi
ids = phi > 0;
Qflux = zeros(size(region.x));
Qflux(ids) = theta(ids).^2.*(pi - theta(ids)).^2.*phi(ids).^2.*(pi - phi(ids)).^2;
end