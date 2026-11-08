function main4()
run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'startup.m'));   % add src/ to the path
% MAIN4 - GPS Line of Sight (LoS) Coverage para EETAC
% NACC - Lab. Session 3

close all;

% Constantes físicas WGS84 / Kepler
G   = 6.67384e-11;       % Constante gravitacional universal
Me  = 5.972e+24;         % Masa de la Tierra
Oe  = 7.2921151467e-5;   % Velocidad angular de rotación de la Tierra (rad/s)
tol = 1.e-8;             % Tolerancia de convergencia

global fd;
fd = fopen(fullfile(gnss_path('logs'), 'main4.dat'), 'w');

% ---------------------------------------------------------------
% CONFIGURACIÓN DE MODO DE EJECUCIÓN
% ---------------------------------------------------------------
usar_ahora  = false;     % true -> Hora UTC actual | false -> Fecha/Hora fija elegida
hacer_bucle = false;     % true -> Modo interactivo 24h (slider) | false -> Modo práctica (instante único NOW)

if usar_ahora
    now_utc = datetime('now', 'TimeZone', 'UTC');
    DD = day(now_utc); MM = month(now_utc); YYYY = year(now_utc);
    hh_init = hour(now_utc); mm_init = minute(now_utc); ss_init = round(second(now_utc));
    [baseweek, esec_start, NS, Eph] = almanac();
else
    % Fecha y hora fija para el informe
    DD = 14; MM = 10; YYYY = 2026; hh_init = 12; mm_init = 0; ss_init = 0;
    [baseweek, esec_start, NS, Eph] = almanac(DD, MM, YYYY, hh_init, mm_init, ss_init);
end

% ---------------------------------------------------------------
% 1. Coordenadas LLA y ECEF del Usuario (EETAC - Castelldefels)
% ---------------------------------------------------------------
lat_deg = 41 + (16.578 / 60);
lon_deg = 1 + (59.240 / 60);
alt_m   = 51;

phi      = deg2rad(lat_deg);
lambda   = deg2rad(lon_deg);
xyz_user = lla2xyz([phi, lambda, alt_m]);

% Configuración temporal
paso_sec  = 60;                        % Intervalo de 1 minuto
num_pasos = (24 * 3600) / paso_sec;    % 1440 pasos temporales

if hacer_bucle
    % ---------------------------------------------------------------
    % MODO INTERACTIVO (24 Horas)
    % ---------------------------------------------------------------
    AZ_matrix    = zeros(NS, num_pasos + 1);
    ELEV_matrix  = zeros(NS, num_pasos + 1);
    RANGE_matrix = zeros(NS, num_pasos + 1);
    
    fprintf('Precalculando orbitales a resolución de 1 minuto para %02d/%02d/%d...\n', DD, MM, YYYY);
    for s = 1:NS
        id  = Eph(s, 1); e   = Eph(s, 3); toa = Eph(s, 4);
        io  = Eph(s, 5); dO  = Eph(s, 6); a   = Eph(s, 7)^2;
        Lo  = Eph(s, 8); w   = Eph(s, 9); Mo  = Eph(s, 10);
        
        Oo = Lo - Oe * toa;
        
        for k = 0:num_pasos
            t_sec = esec_start + k * paso_sec;
            dt = t_sec - toa;
            
            % Registro de depuración en la hora inicial
            if k == round((hh_init*3600 + mm_init*60) / paso_sec)
                fprintf(fd, "\nid = %d, Oo = %f, esec = %f, dt = %f\n", id, mod(Oo, 2 * pi), t_sec, dt);
            end
            
            ecef_sat = kepler2ecef(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);
            rho_ecef = ecef_sat - xyz_user;
            ned_vec  = ecef2ned(rho_ecef, phi, lambda);
            [r, az, elev] = ned2spherical(ned_vec);
            
            AZ_matrix(s, k + 1)    = az;
            ELEV_matrix(s, k + 1)  = elev;
            RANGE_matrix(s, k + 1) = r / 1000;
        end
    end
else
    % ---------------------------------------------------------------
    % MODO ESTÁNDAR PRÁCTICA (Instante Único)
    % ---------------------------------------------------------------
    visible_prns = []; visible_az = []; visible_el = []; visible_r = [];
    t_sec = esec_start;
    
    for s = 1:NS
        id  = Eph(s, 1); e   = Eph(s, 3); toa = Eph(s, 4);
        io  = Eph(s, 5); dO  = Eph(s, 6); a   = Eph(s, 7)^2;
        Lo  = Eph(s, 8); w   = Eph(s, 9); Mo  = Eph(s, 10);
        
        Oo = Lo - Oe * toa;
        dt = t_sec - toa;
        
        % Formato estricto de depuración
        fprintf(fd, "\nid = %d, Oo = %f, esec = %f, dt = %f\n", id, mod(Oo, 2 * pi), t_sec, dt);
        
        ecef_sat = kepler2ecef(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);
        rho_ecef = ecef_sat - xyz_user;
        ned_vec  = ecef2ned(rho_ecef, phi, lambda);
        [r, az, elev] = ned2spherical(ned_vec);
        
        if elev >= 10
            visible_prns = [visible_prns, id];
            visible_az   = [visible_az, az];
            visible_el   = [visible_el, elev];
            visible_r    = [visible_r, r / 1000];
        end
    end
end

% ---------------------------------------------------------------
% INICIALIZACIÓN DE LA VENTANA GRÁFICA Y ESFERA POLAR
% ---------------------------------------------------------------
hFig = figure(111);
set(hFig, 'Color', 'w', 'Position', [100 40 880 900], ...
    'Name', 'GPS Sky Plot & Interactive Inspector', 'NumberTitle', 'off');
daspect([1 1 1]); hold on;

max_elev    = 90;
min_elev    = 10;
grey        = [0.60, 0.60, 0.60];
legendangle = pi / 4;

% Máscara de elevación (0º - 10º)
r_max = max_elev; p_max = -r_max / 2;
rectangle('Position', [p_max p_max r_max r_max], 'Curvature', [1,1], ...
          'LineWidth', 1.2, 'EdgeColor', [0.85 0.15 0.15], 'FaceColor', [1 0.92 0.92]);
r_valid = max_elev - min_elev; p_valid = -r_valid / 2;
rectangle('Position', [p_valid p_valid r_valid r_valid], 'Curvature', [1,1], ...
          'LineStyle', '-', 'LineWidth', 1.2, 'EdgeColor', [0.85 0.15 0.15], 'FaceColor', 'w');

% Anillos de elevación
elevations = linspace(min_elev, max_elev, 5);
for idx = 1:length(elevations)
    el_val = elevations(idx);
    r = (max_elev - el_val); p = -r / 2;
    if r ~= 0
        rectangle('Position', [p p r r], 'Curvature', [1,1], ...
                  'LineStyle', ':', 'LineWidth', 0.8, 'EdgeColor', grey);
    else
        plot(0, 0, 'k+', 'LineWidth', 1.2, 'MarkerSize', 7);
    end
    text(-p * cos(legendangle) + 1.2, -p * sin(legendangle) + 1.5, sprintf('%d\\circ', round(el_val)), ...
         'FontSize', 8.5, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
end

% Líneas radiales de azimut
radials = linspace(0, 360, 13);
for idx = 1:12
    px = max_elev * sin(radials(idx) * pi / 180) / 2;
    py = max_elev * cos(radials(idx) * pi / 180) / 2;
    plot([0 px], [0 py], ':', 'Color', grey, 'LineWidth', 0.8);
    text(px * 1.15 - 3, py * 1.15, sprintf('%d\\circ', round(radials(idx))), ...
         'FontSize', 8.5, 'Color', [0.25 0.25 0.25]);
end

% Puntos Cardinales
a = max_elev / 2;
text(0, +a + 15, 'NORTH (0\circ)', 'HorizontalAlignment', 'center', 'FontSize', 9.5, 'FontWeight', 'bold');
text(0, -a - 15, 'SOUTH (180\circ)', 'HorizontalAlignment', 'center', 'FontSize', 9.5, 'FontWeight', 'bold');
text(+a + 21, 0, 'EAST (90\circ)', 'HorizontalAlignment', 'center', 'FontSize', 9.5, 'FontWeight', 'bold');
text(-a - 21, 0, 'WEST (270\circ)', 'HorizontalAlignment', 'center', 'FontSize', 9.5, 'FontWeight', 'bold');
axis([-a - 38, a + 38, -a - 38, a + 38]);
set(gca, 'Visible', 'off');

% Títulos
text(0, a + 27, sprintf('GPS Sky Plot (%02d/%02d/%d)', DD, MM, YYYY), ...
     'HorizontalAlignment', 'center', 'FontSize', 12.5, 'FontWeight', 'bold');
hInfoBanner = text(0, a + 19, '', 'HorizontalAlignment', 'center', 'FontSize', 9.5, ...
                   'FontWeight', 'bold', 'Color', [0.1 0.3 0.6], 'Visible', 'off');
hBottomText = text(0, -a - 26, '', 'HorizontalAlignment', 'center', ...
                   'FontSize', 10.5, 'FontWeight', 'bold', 'Color', [0.15 0.15 0.15]);

sat_colors = lines(NS);
hDynamicObjects = [];

if hacer_bucle
    % Crear controles interactivos (Slider)
    init_hour_val = hh_init + mm_init/60;
    uicontrol('Parent', hFig, 'Style', 'slider', 'Units', 'normalized', ...
        'Min', 0, 'Max', 24, 'Value', init_hour_val, ...
        'SliderStep', [1/1440, 1/24], ...
        'Position', [0.18 0.022 0.64 0.028], ...
        'Callback', @onSliderChange);
    uicontrol('Parent', hFig, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.05 0.020 0.11 0.028], 'String', '00:00 UTC', ...
        'BackgroundColor', 'w', 'FontWeight', 'bold', 'FontSize', 9.5);
    uicontrol('Parent', hFig, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.84 0.020 0.11 0.028], 'String', '24:00 UTC', ...
        'BackgroundColor', 'w', 'FontWeight', 'bold', 'FontSize', 9.5);

    visible_prns = []; visible_az = []; visible_el = [];
    drawDynamicElements(init_hour_val);
else
    % Dibujar satélites para el instante único
    for idx = 1:length(visible_prns)
        prn_id  = visible_prns(idx);
        az_curr = visible_az(idx);
        el_curr = visible_el(idx);
        
        r_c = (max_elev - el_curr) / 2;
        xc  = r_c * sin(deg2rad(az_curr));
        yc  = r_c * cos(deg2rad(az_curr));
        
        plot(xc, yc, 'o', 'MarkerSize', 11, 'MarkerFaceColor', sat_colors(idx, :), ...
             'MarkerEdgeColor', [0.15 0.15 0.15], 'LineWidth', 1.1);
        text(xc, yc, sprintf('%d', prn_id), 'Color', 'w', 'FontSize', 7, ...
             'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
    set(hBottomText, 'String', sprintf('EETAC (Castelldefels) - %02d:%02d UTC | Visible SVs: %d', ...
                                       hh_init, mm_init, length(visible_prns)));
end

% ---------------------------------------------------------------
% Volcado final en main4.dat
% ---------------------------------------------------------------
n = length(visible_prns);
fprintf(fd, "\nVisible satellites:\n");
for j = 1:n
    fprintf(fd, "prn = %d, azimuth = %f, elevation = %f\n", visible_prns(j), visible_az(j), visible_el(j));
end
fclose(fd);

% ---------------------------------------------------------------
% Funciones anidadas para el modo interactivo
% ---------------------------------------------------------------
    function onSliderChange(src, ~)
        val = get(src, 'Value');
        drawDynamicElements(val);
    end

    function drawDynamicElements(current_hour)
        if ~isempty(hDynamicObjects)
            delete(hDynamicObjects(isvalid(hDynamicObjects)));
            hDynamicObjects = [];
        end
        
        k_idx = round(current_hour * 3600 / paso_sec) + 1;
        k_idx = max(1, min(num_pasos + 1, k_idx));
        
        hh = floor(current_hour);
        mm = round((current_hour - hh) * 60);
        if mm == 60, hh = hh + 1; mm = 0; end
        
        visible_prns = []; visible_az = []; visible_el = [];
        
        for s = 1:NS
            col = sat_colors(s, :);
            az_track = AZ_matrix(s, 1:k_idx);
            el_track = ELEV_matrix(s, 1:k_idx);
            vis_mask = el_track >= 9.8;
            
            if any(vis_mask)
                r_track = (max_elev - el_track) / 2;
                x_track = r_track .* sin(deg2rad(az_track));
                y_track = r_track .* cos(deg2rad(az_track));
                
                x_track(~vis_mask) = NaN;
                y_track(~vis_mask) = NaN;
                
                hTr = plot(x_track, y_track, '-', 'Color', col, 'LineWidth', 1.5);
                hDynamicObjects = [hDynamicObjects; hTr];
            end
        end
        
        for s = 1:NS
            prn_id  = Eph(s, 1);
            col     = sat_colors(s, :);
            az_curr = AZ_matrix(s, k_idx);
            el_curr = ELEV_matrix(s, k_idx);
            r_curr  = RANGE_matrix(s, k_idx);
            
            if el_curr >= min_elev
                r_c = (max_elev - el_curr) / 2;
                xc  = r_c * sin(deg2rad(az_curr));
                yc  = r_c * cos(deg2rad(az_curr));
                
                hM = plot(xc, yc, 'o', 'MarkerSize', 11, 'MarkerFaceColor', col, ...
                          'MarkerEdgeColor', [0.15 0.15 0.15], 'LineWidth', 1.1, ...
                          'ButtonDownFcn', @(~,~) clickSatCallback(prn_id, az_curr, el_curr, r_curr, hh, mm));
                
                hT = text(xc, yc, sprintf('%d', prn_id), 'Color', 'w', 'FontSize', 7, ...
                          'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                          'VerticalAlignment', 'middle', ...
                          'ButtonDownFcn', @(~,~) clickSatCallback(prn_id, az_curr, el_curr, r_curr, hh, mm));
                
                hDynamicObjects = [hDynamicObjects; hM; hT];
                
                visible_prns = [visible_prns, prn_id];
                visible_az   = [visible_az, az_curr];
                visible_el   = [visible_el, el_curr];
            end
        end
        
        set(hBottomText, 'String', sprintf('EETAC (Castelldefels) - %02d:%02d UTC | Visible SVs: %d', ...
                                           hh, mm, length(visible_prns)));
    end

    function clickSatCallback(prn_id, az_val, el_val, dist_km, hh, mm)
        info_str = sprintf('PRN-%02d (%02d:%02d UTC)  |  Azimuth: %.1f\\circ  |  Elevation: %.1f\\circ  |  Range: %.1f km', ...
                           prn_id, hh, mm, az_val, el_val, dist_km);
        set(hInfoBanner, 'String', info_str, 'Visible', 'on');
    end
end
