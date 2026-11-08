% Convert from LLA coordinates to cartesian (x,y,z) assuming WGS84 ellipsoid
% lla (1x3) = input latitude [rad], longitude [rad] and height [m]
% xyz (1x3) = computed cartesian coordinates [m]

function xyz = lla2xyz(lla)
a  = 6378137;               % WGS84 semi-major axis [m]
e2 = 0.00669437999014;      % WGS84 first eccentricity squared (e^2)

lat = lla(1);               % Latitude [rad]
lon = lla(2);               % Longitude [rad]
h   = lla(3);               % Altitude [m]

% Curvatura en el primer vertical (N)
N = a / sqrt(1 - e2 * (sin(lat))^2);

% Coordenadas cartesianas ECEF
x = (N + h) * cos(lat) * cos(lon);
y = (N + h) * cos(lat) * sin(lon);
z = (N * (1 - e2) + h) * sin(lat);

xyz = [x, y, z];

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "xyz = %f, %f, %f\n", xyz);
end
end