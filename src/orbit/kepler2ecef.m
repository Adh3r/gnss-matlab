% Compute ECEF coordinates of Sat. at time = 'ToA + dt' given orbital parameters

function ecef = kepler2ecef(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io)
M = mean_anomaly(G, Me, a, Mo, dt);
E = eccentric(e, tol, M);
v = true_anomaly(e, E);
[xp, yp] = orbitcoords(v, w, a, e, E);
ecef = satecef(Oe, Oo, dO, dt, io, xp, yp);

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "ecef = %f, %f, %f\n", ecef);
end
end