function v = true_anomaly(e, E)
v = 2 * atan2(sqrt(1 + e) * sin(E/2), sqrt(1 - e) * cos(E/2));

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "v = %f\n", mod(v, 2*pi));
end
end