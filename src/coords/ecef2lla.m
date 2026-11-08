% ECEF2LLA  Convert cartesian ECEF coordinates to geodetic LLA coordinates (datum WGS-84)
%           Closed-form (non-iterative) algorithm of the lab statement (Heikkinen).
% ecef = (1x3) vector containing the current ecef coordinates of sat. [m]
% lla  = (1x3) vector containing the current (lat[deg], long[deg], alt[m]) coordinates of sat.

function lla = ecef2lla(ecef)

x = ecef(1);
y = ecef(2);
z = ecef(3);

% WGS-84 datum
a  = 6378137;                 % semi-major axis [m]
e2 = 0.00669437999014;        % first eccentricity squared (e^2)
b  = a * sqrt(1 - e2);        % semi-minor axis [m]
ep2 = (a^2 - b^2) / b^2;      % second eccentricity squared (e'^2)

% Closed-form algorithm
r  = sqrt(x^2 + y^2);
E2 = a^2 - b^2;
F  = 54 * b^2 * z^2;
G  = r^2 + (1 - e2) * z^2 - e2 * E2;
C  = e2^2 * F * r^2 / G^3;
s  = (1 + C + sqrt(C^2 + 2 * C))^(1/3);
P  = F / (3 * (s + 1/s + 1)^2 * G^2);
Q  = sqrt(1 + 2 * e2^2 * P);
r0 = -P * e2 * r / (1 + Q) + sqrt(0.5 * a^2 * (1 + 1/Q) - P * (1 - e2) * z^2 / (Q * (1 + Q)) - 0.5 * P * r^2);
U  = sqrt((r - e2 * r0)^2 + z^2);
V  = sqrt((r - e2 * r0)^2 + (1 - e2) * z^2);
z0 = b^2 * z / (a * V);

alt  = U * (1 - b^2 / (a * V));            % altitude over the ellipsoid [m]
lat  = atan2(z + ep2 * z0, r) * 180 / pi;  % geodetic latitude [deg]
long = atan2(y, x) * 180 / pi;             % longitude [deg]

lla = [lat, long, alt];
if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "lat = %f, long = %f, alt = %f\n", lat, long, alt);
end

end
