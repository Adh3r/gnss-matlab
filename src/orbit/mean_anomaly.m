function M = mean_anomaly(G, Me, a, Mo, dt)
n = sqrt(G * Me / (a^3));
M = Mo + n * dt;

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "dt = %f, M = %f\n", dt, mod(M, 2*pi));
end
end