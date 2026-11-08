% =========================================================================
% LAB 4 - STEP 3: main5.m
% Cálculo y representación gráfica de DoP a lo largo de 6 horas
% (Esquema de colores alineado con gnssmissionplanning.com)
% =========================================================================
clear all;
close all;
run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'startup.m'));   % add src/ to the path

% Constantes físicas y configuración
G   = 6.67384e-11;          % Gravitational constant
Me  = 5.972e+24;            % Earth Mass
Oe  = 7.2921151467e-5;      % Earth rotation angular velocity (rad/s)
tol = 1.e-8;                % Tolerance for convergence

% Abrir archivo de depuración
global fd1;
fd1 = fopen(fullfile(gnss_path('logs'), 'main5.dat'), 'w');

% 1. Época inicial (coincidente con el almanaque local almanac_week_0392.319488.txt)
DD = 14; MM = 10; YYYY = 2026;
hh = 12; mm = 00; ss = 00;
[~, esec_start, NS, Eph] = almanac(DD, MM, YYYY, hh, mm, ss);

% 2. Posición del usuario en EETAC [lat, long, alt]
ulla = [41.275556, 1.986944, 4];

% 3. Bucle temporal para calcular DoP durante 6 horas (paso de 1 minuto)
duration_hours = 6;
step_minutes   = 1;
total_steps    = (duration_hours * 60) / step_minutes;

tm   = zeros(1, total_steps + 1);
gdop = zeros(1, total_steps + 1);
pdop = zeros(1, total_steps + 1);
hdop = zeros(1, total_steps + 1);
vdop = zeros(1, total_steps + 1);
tdop = zeros(1, total_steps + 1);

for k = 0:total_steps
    elapsed_min = k * step_minutes;
    esec = esec_start + elapsed_min * 60;
    
    [g, p, h, v, t] = dop(Oe, G, Me, tol, esec, ulla, NS, Eph);
    
    tm(k+1)   = elapsed_min;
    gdop(k+1) = g;
    pdop(k+1) = p;
    hdop(k+1) = h;
    vdop(k+1) = v;
    tdop(k+1) = t;
end

% 4. Representación gráfica de los DoPs con paleta de colores idéntica a la Web
figure('Name', 'GPS Dilution of Precision (DoP) - 6 Horas', 'Color', 'w');

plot(tm, gdop, 'Color', [0.25 0.40 0.95], 'LineWidth', 1.5); hold on; % Azul (GDOP)
plot(tm, pdop, 'Color', [0.20 0.75 0.95], 'LineWidth', 1.5);          % Celeste (PDOP)
plot(tm, hdop, 'Color', [0.30 0.80 0.35], 'LineWidth', 1.5);          % Verde (HDOP)
plot(tm, vdop, 'Color', [0.95 0.40 0.40], 'LineWidth', 1.5);          % Rojo Coral (VDOP)
plot(tm, tdop, 'Color', [0.75 0.20 0.75], 'LineWidth', 1.5);          % Magenta (TDOP)

grid on;
xlabel('Elapsed Time (minutes)', 'FontWeight', 'bold');
ylabel('DOP Factor', 'FontWeight', 'bold');
title(sprintf('GPS DoP en EETAC (%02d/%02d/%d %02d:%02d UTC)', DD, MM, YYYY, hh, mm), 'FontWeight', 'bold');

xbounds = xlim();
set(gca, 'xtick', xbounds(1):60:xbounds(2));
legend('GDOP', 'PDOP', 'HDOP', 'VDOP', 'TDOP', 'Location', 'northeast');

% Cerrar el fichero de depuración de forma segura
if ismember("fd1", who("global")) && ~isempty(fd1)
    try
        fclose(fd1);
    catch
    end
end
