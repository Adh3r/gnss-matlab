% =========================================================================
% LAB 4 - STEP 5: main6.m
% Posicionamiento Iterativo por Mínimos Cuadrados (Grupo 18)
% =========================================================================
% Lab. Group = 18
% DD, MM, YYYY, hh, mm, ss = 5, 10, 2026, 19, 32, 59
%
% Visible satellites and pseudoranges:
% 2 23539247.563891
% 8 22210360.931565
% 10 20589492.404730
% 14 22962052.340541
% 15 22685456.754216
% 20 24287292.281321
% 22 23648471.353785
% 23 20904026.071523
% 24 23304295.251366
% 27 23053381.927858
% =========================================================================

clear all;
close all;
run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'startup.m'));   % add src/ to the path

% Constantes físicas WGS-84
G   = 6.67384e-11;          % Constante gravitacional universal [m^3/kg/s^2]
Me  = 5.972e+24;            % Masa de la Tierra [kg]
Oe  = 7.2921151467e-5;      % Velocidad angular de rotación terrestre [rad/s]
tol = 1.e-8;                % Tolerancia de convergencia orbital

colorarray = 'rgbcmyk';

global fd1;
fd1 = fopen(fullfile(gnss_path('logs'), 'main6.dat'), 'w');

% 1. Carga de datos del Grupo 18
DD = 5; MM = 10; YYYY = 2026;
hh = 19; mm = 32; ss = 59;

satlist = [2, 8, 10, 14, 15, 20, 22, 23, 24, 27];

pr = [ ...
    23539247.563891, ...
    22210360.931565, ...
    20589492.404730, ...
    22962052.340541, ...
    22685456.754216, ...
    24287292.281321, ...
    23648471.353785, ...
    20904026.071523, ...
    23304295.251366, ...
    23053381.927858  ...
];

% 2. Efemérides y Posición Inicial de Referencia (EETAC)
[~, esec, NS, Eph] = almanac(DD, MM, YYYY, hh, mm, ss);

reflat  = 41 + (16.578 / 60);
reflong = 1 + (59.240 / 60);
refalt  = 4.0;

refecef = lla2xyz([deg2rad(reflat), deg2rad(reflong), refalt]);
cdt = 0.0;

% 3. Bucle de Mínimos Cuadrados
niter = 0;
max_iter = 25;
tol_displ = 10.0; % Criterio de parada: desplazamiento < 10 m

computedlla = [];

fprintf('\n========================================================================================\n');
fprintf('  ITERACIÓN   |   DESPLAZAMIENTO (m)  |   LATITUD (º)   |   LONGITUD (º)  |  ALTITUD (m)\n');
fprintf('========================================================================================\n');

while niter < max_iter
    niter = niter + 1;
    
    [gr, H] = reference(Oe, G, Me, tol, esec, refecef, NS, Eph, satlist);
    
    delta_rho = (pr - gr - cdt)';
    A = [-H(:, 1:3), ones(length(satlist), 1)];
    
    delta_u = pinv(A) * delta_rho;
    
    refecef = refecef + delta_u(1:3)';
    cdt     = cdt + delta_u(4);
    
    lla_k = ecef2lla(refecef);
    computedlla(niter, :) = lla_k;
    
    displ = norm(delta_u(1:3));

    displ_vector(niter) = displ;
    
    fprintf('    Iter %02d   |   %18.2f  |   %11.6f   |   %11.6f   |  %10.2f\n', ...
            niter, displ, lla_k(1), lla_k(2), lla_k(3));
        
    if displ < tol_displ
        break;
    end
end

% 4. Volcado en main6.dat (Formato Estricto del Enunciado)
if ismember("fd1", who("global")) && ~isempty(fd1)
    try
        fprintf(fd1, "\nNumber of iterations = %d\n", niter);
        fprintf(fd1, "Computed LLA = %f %f %f\n", computedlla(niter, 1), computedlla(niter, 2), computedlla(niter, 3));
        fclose(fd1);
    catch
    end
end

% 5. Representación en Mapa Mundial según Prototipo del Laboratorio
offsets = [
     4,  3;   % Iteración 1
    -8,  4;   % Iteración 2
     4, -4;   % Iteración 3
    -9, -3;   % Iteración 4
     4,  1    % Iteración 5
];

plotworld();
set(gcf, 'Name', 'GPS Iterative Positioning Convergence', 'Color', 'w');
hold on;

% Dibujar punto inicial EETAC
plot(reflong, reflat, '*r', 'MarkerSize', 10);
text(reflong + 3, reflat + 3, 'EETAC (Inicio)', 'FontSize', 8.5, 'FontWeight', 'bold', 'Color', 'r');

% Dibujar línea de trayectoria punteada de conexión
track_lon = [reflong; computedlla(:, 2)];
track_lat = [reflat; computedlla(:, 1)];
plot(track_lon, track_lat, '--k', 'LineWidth', 0.8);

% Dibujar cada iteración con color dinámico y etiqueta desplazada
for j = 1:size(computedlla, 1)
    color = mod(j - 1, 7) + 1;
    
    plot(computedlla(j, 2), computedlla(j, 1), sprintf('*%s', colorarray(color)), ...
         'MarkerSize', 10);
    
    if j <= size(offsets, 1)
        dx = offsets(j, 1);
        dy = offsets(j, 2);
    else
        dx = 2; dy = 1;
    end
    
    text(computedlla(j, 2) + dx, computedlla(j, 1) + dy, sprintf(' %d', j), ...
         'FontSize', 8.5, 'FontWeight', 'bold');
     
    if usejava("desktop"), pause(0.4); end   % animate only in interactive sessions
end

% Gráfico Adicional para el Reporte: Convergencia Logarítmica del Desplazamiento
if exist('displ_vector', 'var') && length(displ_vector) > 1
    figure('Name', 'LS Convergence Analysis', 'Color', 'w');
    semilogy(1:niter, displ_vector, '-or', 'LineWidth', 1.8, 'MarkerFaceColor', 'r');
    grid on; box on;
    xlabel('Iteration Number', 'FontWeight', 'bold');
    ylabel('Displacement Magnitude ||\Delta u|| (m)', 'FontWeight', 'bold');
    title('Least Squares Convergence Rate', 'FontSize', 10, 'FontWeight', 'bold');
end
