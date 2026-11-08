clear all;
close all;
run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'startup.m'));   % add src/ to the path

% Universal and planetary constants
G   = 6.67384e-11;          % Universal gravitational constant
Me  = 5.972e+24;           % Mass of the Earth
Oe  = 7.2921151467e-5;     % Angular velocity of Earth's rotation (rad/s)
tol = 1.e-8;              % Convergence tolerance for Kepler

global fd;
fd = fopen(fullfile(gnss_path('logs'), 'main1.dat'), 'w');

% Draw the world map
plotworld();

% Target date and time for the calculation (modify if a specific one is required)
DD = 1; MM = 10; YYYY = 2026; hh = 10; mm = 21; ss = 7;
esec = gpstime(DD, MM, YYYY, hh, mm, ss);

% ******** Week 390 almanac for PRN-18 ********
% (file downloaded by gpstime: almanac_week_0390.405504.txt)
% ID:                         18
% Health:                     000
% Eccentricity:               0.6573200226E-002
% Time of Applicability(s):  405504.0000
% Orbital Inclination(rad):   0.9699576238
% Rate of Right Ascen(r/s):  -0.8068907531E-008
% SQRT(A)  (m 1/2):           5153.558105
% Right Ascen at Week(rad):  -0.6772630040E+000
% Argument of Perigee(rad):  -2.812811435
% Mean Anom(rad):             0.9359263948E+000
% Af0(s):                    -0.2431869507E-003
% Af1(s/s):                   0.7275957614E-011
% week:                        390

% YUMA almanac data for PRN-18 (Week 390, ToA = 405504 s)
id   = 18;                      % sat. identifier
e    = 0.6573200226E-002;       % orbit eccentricity
toa  = 405504.0000;             % Time of Applicability [seconds within current week]
io   = 0.9699576238;            % orbit inclination [rad]
dO   = -0.8068907531E-008;      % derivative of right ascension of AN [rad/s]
a    = (5153.558105)^2;         % orbit semi-major axis [m]
Lo   = -0.6772630040E+000;      % longitude of AN at week epoch [rad] (uncorrected)
w    = -2.812811435;            % argument of perigee [rad]
Mo   = 0.9359263948E+000;       % Mean Anomaly at ToA [rad]
af0  = -0.2431869507E-003;      % SV clock bias [s] (not used)
af1  = 0.7275957614E-011;       % SV clock drift [s/s] (not used)
week = 390;                     % GPS week number (modulo 1024)

% Step 1: Calculating dt and Oo at ToA
dt = esec - toa;
Oo = Lo - Oe * toa;
fprintf(fd, "Oo = %f, esec = %f, dt = %f\n\n", mod(Oo, 2*pi), esec, dt);

% Steps 2 through 7: Initial sub-satellite position
[long_init, lat_init] = subsatellite(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);
plot(long_init, lat_init, 'r*', 'LineWidth', 2);
text(long_init + 2, lat_init - 1, sprintf('PRN-%02d', id), 'Color', 'red', 'FontWeight', 'bold');


% Step 9: Track the Earth for 24 hours (5-minute intervals = 300 s)
paso_sec = 300;
num_pasos = (24 * 3600) / paso_sec;

for k = 1:num_pasos
    dt_loop = dt + k * paso_sec;
    [long_k, lat_k] = subsatellite(Oe, G, Me, a, Mo, dt_loop, e, tol, w, Oo, dO, io);
    plot(long_k, lat_k, 'r.', 'MarkerSize', 5);
end

fclose(fd);
