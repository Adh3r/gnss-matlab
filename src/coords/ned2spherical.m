% Convert from cartesian NED to local spherical coordinates
% xyz (1x3) = input cartesian NED coordinates [m]
% r = distance [m]
% az = azimuth [degrees]
% elev = elevation [degrees]

function [r, az, elev] = ned2spherical(xyz)
N = xyz(1);
E = xyz(2);
D = xyz(3);

% Distancia geométrica
r = sqrt(N^2 + E^2 + D^2);

% Elevación (de -90 a 90 grados)
elev = rad2deg(asin(-D / r));

% Azimut (de 0 a 360 grados sin ambigüedad mediante atan2)
az = rad2deg(atan2(E, N));
if az < 0
    az = az + 360;
end

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "r = %f, az = %f, elev = %f\n", r, az, elev);
end
end