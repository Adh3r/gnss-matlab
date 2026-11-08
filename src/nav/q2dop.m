% Compute DoP's given matrix Q'
% Q (4x4) = matrix for computing DoP (Q' in NED frame)
% gdop = Geometric DOP
% pdop = Positioning DOP
% hdop = Horizontal plane DOP
% vdop = Vertical DOP
% tdop = Time DOP

function [gdop, pdop, hdop, vdop, tdop] = q2dop(Q)

    % Extracción de los elementos de la diagonal principal de Q'
    q_NN  = Q(1,1);
    q_EE  = Q(2,2);
    q_DD  = Q(3,3);
    q_ct  = Q(4,4);

    % Cálculo de los distintos coeficientes de Dilution of Precision (DoP)
    hdop = sqrt(q_NN + q_EE);
    vdop = sqrt(q_DD);
    pdop = sqrt(q_NN + q_EE + q_DD);
    tdop = sqrt(q_ct);
    gdop = sqrt(pdop^2 + tdop^2);

    % Escritura en el fichero de depuración si está activo fd1
    if ismember("fd1", who("global"))
        global fd1;
        fprintf(fd1, "gdop = %f, pdop = %f, hdop = %f, vdop = %f, tdop = %f\n", ...
                gdop, pdop, hdop, vdop, tdop);
    end
end