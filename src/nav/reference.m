% Given GPS sats. ephemeris and time "esec", compute geometric ranges and system matrix
% at reference position with coordinates "refecef"
% Oe = Earth rotation angular velocity [rad/s]
% G = Gravitational constant
% Me = Earth Mass
% tol = tolerance for convergence
% esec = elapsed time [s] after week epoch
% refecef (1 x 3) = reference position ECEF coords [x, y, z] in meters
% NS = number of GPS satellites contained in the almanac
% Eph (NS x 13) = almanac with all GPS satellites ephemeris
% satlist (1 x n) = ID's of visible sats at actual user position
% gr (1 x n) = vector of geometric ranges [m] as seen from reference position
% H (n x 4) = system matrix

function [gr, H] = reference(Oe, G, Me, tol, esec, refecef, NS, Eph, satlist)

    n  = length(satlist);
    gr = zeros(1, n);
    H  = zeros(n, 4);

    % Bucle para cada satélite contenido en satlist
    for j = 1:n
        prn_id = satlist(j);
        
        % Localizar el satélite prn_id en el almanaque Eph
        idx = find(Eph(:, 1) == prn_id, 1);
        if isempty(idx)
            error('El satélite PRN %d no se encuentra en el almanaque.', prn_id);
        end
        
        % Extracción de parámetros orbitales
        e   = Eph(idx, 3);
        toa = Eph(idx, 4);
        io  = Eph(idx, 5);
        dO  = Eph(idx, 6);
        a   = Eph(idx, 7)^2;  % SQRT(A)^2 = semieje mayor a
        Oo  = Eph(idx, 8) - Oe * toa;   % Omega0 = Omega_week - Oe*ToA
        w   = Eph(idx, 9);
        Mo  = Eph(idx, 10);
        
        % Diferencia temporal dt con ajuste por cambio de semana GPS
        dt = esec - toa;
        if (dt > 302400)
            dt = dt - 604800;
        elseif (dt < -302400)
            dt = dt + 604800;
        end
        
        % Posición ECEF del satélite mediante kepler2ecef
        sat_pos = kepler2ecef(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);
        
        % Vector desde la posición de referencia hacia el satélite
        gr_vec = sat_pos - refecef;
        
        % Distancia geométrica (rango geométrico)
        r_mag = norm(gr_vec);
        gr(j) = r_mag;
        
        % Fila j de la matriz H: [gr_x/gr_i, gr_y/gr_i, gr_z/gr_i, 1]
        H(j, :) = [gr_vec(1)/r_mag, gr_vec(2)/r_mag, gr_vec(3)/r_mag, 1];
    end

    % Escritura segura en fichero de depuración
    if ismember("fd1", who("global"))
        global fd1;
        try
            fprintf(fd1, "\nH matrix:\n");
            for j = 1:n
                fprintf(fd1, "%f %f %f %f\n", H(j, :));
            end
        catch
            % Si fd1 está cerrado o no es válido, se ignora la impresión sin error
        end
    end

end