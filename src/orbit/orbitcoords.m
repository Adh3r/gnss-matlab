function [xp, yp] = orbitcoords(v, w, a, e, E)
r = a * (1 - e * cos(E));
u = w + v;

xp = r * cos(u);
yp = r * sin(u);

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "xp = %f, yp = %f\n", xp, yp);
end
end