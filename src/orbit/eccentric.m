function E = eccentric(e, tol, M)
E = M;
delta = 1;

while abs(delta) > tol
    f = E - e * sin(E) - M;
    f_prime = 1 - e * cos(E);
    delta = f / f_prime;
    E = E - delta;
end

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "E = %f\n", mod(E, 2*pi));
end
end