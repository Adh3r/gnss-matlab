% MAIN3 - Ground track of an IRIDIUM NEXT satellite (group 18) during a complete orbit
% NACC - Lab. session 2 (part 2)
clear all
close all
run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'startup.m'));   % add src/ to the path

G = 6.67384e-11;         % Gravitational constant
Me = 5.972e+24;          % Earth Mass
Oe = 7.2921151467e-5;    % Earth rotation angular velocity (rad/s)
tol = 1.e-8;             % tolerance for convergence

global fd;
fd = fopen(fullfile(gnss_path('logs'), 'main3.dat'), 'w');

plotworld();

% Date and time (UTC) printed in Group_18.pdf
DD = 30; MM = 9; YYYY = 2026; hh = 20; mm = 25; ss = 8;

% IRIDIUM 170
% 1 43930U 19002J   26273.85494888  .00000304  00000+0  44338-4 0  9997
% 2 43930  86.6070 309.3776 0002386  91.2600 268.8890 14.72247722414806

id = 170;                % sat. identifier
toa = 273.85494888;      % ToA [days within current year]
io = 86.6070;            % orbit inclination (deg)
raan = 309.3776;         % RA of AN (deg)
e = 0.0002386;           % orbit eccentricity
w = 91.2600;             % argument of the perigee (deg)
Mo = 268.8890;           % Mean anomaly at ToA [deg]
n = 14.72247722;         % mean motion [rev/day]

[dt, GASTdegToA] = time2toa(toa, DD, MM, YYYY, hh, mm, ss);
% [dt, GASTdegToA] = time2toa(toa);

% ---- Step 2: adapt units/format for subsatellite.m ----
n_rad = n * 2 * pi / 86400;                        % mean motion [rad/s]
a  = (G * Me / n_rad^2)^(1/3);                     % semi-major axis [m] (Kepler's 3rd law)
Oo = deg2rad(raan - GASTdegToA);                   % longitude of AN at ToA [rad] = RA(AN) - GAST(ToA)
io = deg2rad(io);                                  % [rad]
w  = deg2rad(w);                                   % [rad]
Mo = deg2rad(Mo);                                  % [rad]
dO = 0;                                            % no information in the TLE

fprintf(fd, "io = %f, a = %f, w = %f, Mo = %f, Oo = %f\n\n", io, a, mod(w, 2 * pi), ...
        mod(Mo, 2 * pi), mod(Oo, 2 * pi));

% ---- Step 3: sub-satellite point at the given date ----
[long, lat] = subsatellite(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);

plot(long, lat, 'r*')
text(long + 2, lat + 1, sprintf('%d', id));

% ---- Step 4: complete orbit, 30 s steps ----
T = 2 * pi / n_rad;                                % orbital period [s]
paso = 30;                                         % time step [s]
N = ceil(T / paso);                                % number of steps for one complete orbit
for k = 1:N
    [long, lat] = subsatellite(Oe, G, Me, a, Mo, dt + k * paso, e, tol, w, Oo, dO, io);
    plot(long, lat, 'r.', 'MarkerSize', 8);
end
title(sprintf('Ground track of IRIDIUM %d (group 18), one orbit from %02d/%02d/%d %02d:%02d:%02d UTC', id, DD, MM, YYYY, hh, mm, ss));

fclose(fd);
