% Compute DoP's at "ulla" position and time "esec" given GPS sats. ephemeris
% Oe = Earth rotation angular velocity [rad/s]
% G = Gravitational constant
% Me = Earth Mass
% tol = tolerance for convergence
% esec = elapsed time [s] after week epoch
% ulla (1x3) = user LLA [lat (deg), long (deg), height (m)]
% NS = number of GPS satellites contained in the almanac
% Eph (NS x 13) = almanac with all GPS satellites ephemeris
% gdop = Geometric DOP
% pdop = Positioning DOP
% hdop = Horizontal plane DOP
% vdop = Vertical DOP
% tdop = Time DOP

function [gdop, pdop, hdop, vdop, tdop] = dop(Oe, G, Me, tol, esec, ulla, NS, Eph)

    % 1. Conversión de coordenadas del usuario (grados a radianes) y cálculo ECEF
    ulat_rad  = deg2rad(ulla(1));
    ulong_rad = deg2rad(ulla(2));
    ualt_m    = ulla(3);
    
    % lla2xyz recibe el vector [lat_rad, lon_rad, alt_m]
    uecef = lla2xyz([ulat_rad, ulong_rad, ualt_m]);

    % 2. Inicialización de estructuras de datos
    H = [];
    prn = [];
    azimuth = [];
    elevation = [];
    mask_angle = 10; % Máscara de elevación a 10 grados
    n = 0;

    % 3. Bucle para determinar visibilidad de satélites en el almanaque
    for j = 1:NS
        % Extracción de parámetros orbitales desde Eph(j, :)
        e   = Eph(j, 3);
        toa = Eph(j, 4);
        io  = Eph(j, 5);
        dO  = Eph(j, 6);
        a   = Eph(j, 7)^2;  % SQRT(A)^2 = semieje mayor a
        Oo  = Eph(j, 8) - Oe * toa;   % Omega0 = Omega_week - Oe*ToA
        w   = Eph(j, 9);
        Mo  = Eph(j, 10);
        
        % Diferencia temporal dt entre la época de cálculo (esec) y ToA
        dt = esec - toa;
        if (dt > 302400)
            dt = dt - 604800;
        elseif (dt < -302400)
            dt = dt + 604800;
        end
        
        % Posición ECEF del satélite j a la época esec mediante kepler2ecef
        sat_pos = kepler2ecef(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);
        
        % Vector desde el usuario hacia el satélite y distancia geométrica
        rho_vec = sat_pos - uecef;
        rho = norm(rho_vec);
        
        % Transformación de ECEF a coordenadas locales NED
        ned = ecef2ned(rho_vec, ulat_rad, ulong_rad);
        
        % Conversión NED a coordenadas esféricas [r, az, elev]
        [~, az, el] = ned2spherical(ned);
        
        % Filtrado por máscara de elevación (satélites en Línea de Vista)
        if el >= mask_angle
            n = n + 1;
            
            % Fila n de la matriz H: [dx/rho, dy/rho, dz/rho, 1]
            H(n, :) = [rho_vec(1)/rho, rho_vec(2)/rho, rho_vec(3)/rho, 1];
            
            % Registro de satélites visibles
            prn(n)       = Eph(j, 1);
            azimuth(n)   = az;
            elevation(n) = el;
        end
    end

    % 4. Impresión de satélites visibles en main5.dat si fd1 está abierto
    if ismember("fd1", who("global"))
        global fd1;
        fprintf(fd1, "\nVisible satellites for esec = %6d:\n", floor(esec));
        for j = 1:n
            fprintf(fd1, "prn = %d, azimuth = %f, elevation = %f\n", prn(j), azimuth(j), elevation(j));
        end
    end

    % 5. Cálculo de la matriz Q' (rotada a NED) y coeficientes DoP
    Q = qmat(H, ulat_rad, ulong_rad);
    [gdop, pdop, hdop, vdop, tdop] = q2dop(Q);

end