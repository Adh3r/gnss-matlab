function lla = ecef2lla_bowring(ecef)
% ECEF2LLA_BOWRING Converts ECEF coordinates (x, y, z) to WGS84 Geodetic coordinates (Lat, Lon, Alt)
% Input:  ecef = [x, y, z] in meters
% Output: lla  = [latitude_deg, longitude_deg, altitude_m]

x = ecef(1);
y = ecef(2);
z = ecef(3);

% WGS84 ellipsoid reference parameters
a = 6378137.0;                % Semi-major axis (meters)
f = 1 / 298.257223563;        % Flattening
b = a * (1 - f);              % Semi-minor axis (meters)
e2 = (a^2 - b^2) / a^2;       % First eccentricity squared
e_prime2 = (a^2 - b^2) / b^2; % Second eccentricity squared

% Distance from Z axis (equatorial plane distance)
p = sqrt(x^2 + y^2);

% Auxiliary angle
theta = atan2(z * a, p * b);

% Geodetic Latitude and Longitude (in radians)
lat = atan2(z + e_prime2 * b * (sin(theta))^3, p - e2 * a * (cos(theta))^3);
lon = atan2(y, x);

% Radius of curvature in the prime vertical
N = a / sqrt(1 - e2 * (sin(lat))^2);

% Altitude above ellipsoid
alt = p / cos(lat) - N;

% Convert latitude and longitude from radians to degrees
lla = [lat * 180 / pi, lon * 180 / pi, alt];
end