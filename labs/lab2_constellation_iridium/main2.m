% MAIN2 - Ground track of the FULL GPS constellation for the next hour (NOW -> NOW + 60 min)
% NACC - Lab Session 2 (EETAC)

clear all;
close all;
run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'startup.m'));   % add src/ to the path

% Constantes universales y planetarias
G   = 6.67384e-11;       % Constante gravitacional
Me  = 5.972e+24;         % Masa de la Tierra
Oe  = 7.2921151467e-5;   % Velocidad angular de la Tierra (rad/s)
tol = 1.e-8;             % Tolerancia de convergencia

global fd;
fd = fopen(fullfile(gnss_path('logs'), 'main2.dat'), 'w'); % Fichero de depuración indicado en el PDF

plotworld();

% ---------------------------------------------------------------
% 1. Descarga del almanaque (una sola llamada al inicio)
% ---------------------------------------------------------------
% USE_NOW = true  -> hora UTC actual (descarga el almanaque de Celestrak; requiere red)
% USE_NOW = false -> fecha fija reproducible con el almanaque local (data/almanacs)
USE_NOW = false;

if USE_NOW
    [baseweek, esec, NS, Eph] = almanac();
else
    [baseweek, esec, NS, Eph] = almanac(5, 10, 2026, 20, 45, 07);
end

paso     = 60;            % Paso temporal de la traza [s]
duracion = 3600;          % Ventana de 1 hora hacia el futuro [s]
colores  = hsv(NS);       % Color único para cada satélite

% ---------------------------------------------------------------
% 2. Bucle sobre TODOS los satélites de la matriz Eph (NS x 13)
% ---------------------------------------------------------------
for s = 1:NS
    id  = Eph(s, 1);      % Identificador PRN
    e   = Eph(s, 3);      % Excentricidad
    toa = Eph(s, 4);      % Time of Applicability [s dentro de la semana]
    io  = Eph(s, 5);      % Inclinación [rad]
    dO  = Eph(s, 6);      % Variación de la ascensión recta [rad/s]
    a   = Eph(s, 7)^2;    % Semieje mayor [m] (sqrta^2)
    Lo  = Eph(s, 8);      % Longitud del nodo ascendente en la época de la semana [rad]
    w   = Eph(s, 9);      % Argumento del perigeo [rad]
    Mo  = Eph(s, 10);     % Anomalía media en ToA [rad]
    
    dt0 = esec - toa;     % Tiempo transcurrido desde ToA
    Oo  = Lo - Oe * toa;  % Longitud del nodo ascendente en ToA [rad]
    
    % Registro de depuración en main2.dat
    fprintf(fd, "PRN-%02d: Oo = %f, esec = %f, dt = %f\n\n", id, mod(Oo, 2 * pi), esec, dt0);
    
    % Bucle para proyectar los próximos 60 minutos
    for k = 0:(duracion / paso)
        dt = dt0 + k * paso;
        [long, lat] = subsatellite(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);
        
        % Dibujar traza
        plot(long, lat, '.', 'Color', colores(s, :), 'MarkerSize', 8);
        
        % Identificar la posición inicial (t = NOW)
        if k == 0
            plot(long, lat, 'o', 'Color', colores(s, :), 'MarkerSize', 6, 'LineWidth', 1.5);
            text(long + 2, lat + 1, sprintf('%02d', id), 'FontSize', 8, 'FontWeight', 'bold');
        end
    end
end

title(sprintf('GPS constellation ground track (next 60 min), GPS week %d, %d satellites', baseweek, NS));
fclose(fd);
