% Compute matrix Q' given the matrix of the system of equations and user LLA coords.
% H (n x 4) = matrix of the system of equations
% ulat = user latitude [rad]
% ulong = user longitude [rad]
% Q (4 x 4) = matrix to compute DoP (Q' rotated to NED)

function Q = qmat(H, ulat, ulong)

% 1. Matriz de covarianza de posición en coordenadas ECEF: Q_ecef = (H' * H)^(-1)
Q_ecef = inv(H' * H);

% 2. Matriz de rotación R (de ECEF a NED con componente temporal inalterada)
s_lat = sin(ulat);
c_lat = cos(ulat);
s_lon = sin(ulong);
c_lon = cos(ulong);

R = [ -s_lat*c_lon,  -s_lat*s_lon,   c_lat,  0;
    -s_lon,         c_lon,         0,      0;
    -c_lat*c_lon,  -c_lat*s_lon,  -s_lat,  0;
    0,             0,             0,      1 ];

% 3. Matriz Q' rotada a coordenadas locales NED: Q' = R * Q_ecef * R'
Q = R * Q_ecef * R';

% 4. Escritura en el fichero de depuración si está activo fd1
if ismember("fd1", who("global"))
    global fd1;
    fprintf(fd1, "Q matrix:\n");
    fprintf(fd1, "%f, %f, %f, %f\n", Q(1,:));
    fprintf(fd1, "%f, %f, %f, %f\n", Q(2,:));
    fprintf(fd1, "%f, %f, %f, %f\n", Q(3,:));
    fprintf(fd1, "%f, %f, %f, %f\n", Q(4,:));
end
end