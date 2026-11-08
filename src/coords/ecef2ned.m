% Rotate ECEF cartesian coordinates to local North, East, Down (NED) coordinates
% ecef (1x3) = input cartesian coordinates [m]
% phi = user geodetic latitude [rad]
% lambda = user geodetic longitude [rad]
% ned (1x3) = computed NED coordinates [m]

function ned = ecef2ned(ecef, phi, lambda)
% Matriz de rotación ECEF a NED (transpuesta de NED a ECEF)
R = [ -sin(phi)*cos(lambda), -sin(phi)*sin(lambda),  cos(phi); ...
    -sin(lambda),           cos(lambda),          0; ...
    -cos(phi)*cos(lambda), -cos(phi)*sin(lambda), -sin(phi) ];

% Multiplicación matricial (vector fila por matriz de rotación transpuesta)
ned = (R * ecef')';

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "ned = %f, %f, %f\n", ned);
end
end