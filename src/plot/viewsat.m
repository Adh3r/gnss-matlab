function err = viewsat(AZIMUTH, ELEV, ID, min_elev, max_elev, downstr)
    hFig = figure(111);
    clf(hFig);
    
    % Forzar fondo blanco en la ventana para alto contraste y entrega en PDF
    set(hFig, 'Color', 'w', 'Position', [100 100 850 850]);
    
    daspect([1,1,1]);
    hold on;
    
    grey = [0.45, 0.45, 0.45];
    legendangle = pi / 4;
    
    % 1. Zona por debajo de la máscara de elevación (< min_elev) en rojo claro
    r_max = max_elev;
    p_max = -r_max / 2;
    rectangle('Position', [p_max p_max r_max r_max], 'Curvature', [1,1], ...
              'LineWidth', 1.5, 'EdgeColor', [0.8 0.2 0.2], 'FaceColor', [1 0.88 0.88]);
    
    % 2. Zona de cobertura útil (>= min_elev) en blanco
    r_valid = max_elev - min_elev;
    p_valid = -r_valid / 2;
    rectangle('Position', [p_valid p_valid r_valid r_valid], 'Curvature', [1,1], ...
              'LineStyle', '-', 'LineWidth', 1.5, 'EdgeColor', [0.8 0.2 0.2], 'FaceColor', 'w');
    
    % 3. Anillos concéntricos de elevación (etiquetas claras)
    N = 5;
    elevations = linspace(min_elev, max_elev, N);
    for index = 1:length(elevations)
        elev = elevations(index);
        r = (max_elev - elev);
        p = -r / 2;
        if r ~= 0
            rectangle('Position', [p p r r], 'Curvature', [1,1], ...
                      'LineStyle', ':', 'LineWidth', 1, 'EdgeColor', grey);
        else
            plot(0, 0, 'k+', 'LineWidth', 1.5, 'MarkerSize', 8); % Cenit (90º)
        end
        % Etiquetas de elevación en negrita y color oscuro
        text(-p * cos(legendangle) + 1.2, -p * sin(legendangle) + 1.5, sprintf('%d\\circ', round(elev)), ...
             'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.15 0.15 0.15]);
    end
    
    % 4. Líneas radiales de azimut cada 30º
    N_rad = 12;
    radials = linspace(0, 360, N_rad + 1);
    for index = 1:N_rad
        px = max_elev * sin(radials(index) * pi / 180) / 2;
        py = max_elev * cos(radials(index) * pi / 180) / 2;
        plot([0 px], [0 py], ':', 'Color', grey, 'LineWidth', 0.8);
        text(px * 1.15 - 3, py * 1.15, sprintf('%d\\circ', round(radials(index))), ...
             'FontSize', 9, 'Color', [0.2 0.2 0.2]);
    end
    
    % 5. Puntos cardinales en los bordes
    a = max_elev / 2;
    text(0, +a + 12, 'NORTH (0\circ)', 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    text(0, -a - 12, 'SOUTH (180\circ)', 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    text(+a + 15, 0, 'EAST (90\circ)', 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    text(-a - 15, 0, 'WEST (270\circ)', 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    
    % Fijar límites del gráfico y ocultar ejes cartesianos nativos de MATLAB
    m = 35;
    axis([-a - m, a + m, -a - m, a + m]);
    title('GPS Constellation Sky Plot (LoS Coverage)', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
    set(gca, 'Visible', 'off');
    
    % 6. Marcadores de satélites: Círculos azules rellenos con PRN centrado en blanco
    for index = 1:length(AZIMUTH)
        if (ELEV(index) <= 90 && ELEV(index) >= 0)
            x = (max_elev - ELEV(index)) * sin(pi * AZIMUTH(index) / 180) / 2;
            y = (max_elev - ELEV(index)) * cos(pi * AZIMUTH(index) / 180) / 2;
            
            % Dibujar círculo azul estilo GNSS Mission Planning
            plot(x, y, 'o', 'MarkerSize', 17, 'MarkerFaceColor', [0.15 0.45 0.85], ...
                 'MarkerEdgeColor', [0 0 0.4], 'LineWidth', 1.5);
             
            % Dibujar número del satélite (PRN) centrado en blanco
            text(x, y, sprintf('%d', ID(index)), 'Color', 'w', 'FontSize', 9, ...
                 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle');
        end
    end
    
    % Texto explicativo inferior
    text(0, -a - 25, downstr, 'HorizontalAlignment', 'center', ...
         'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.1]);
    
    hold off;
    err = 0;
end