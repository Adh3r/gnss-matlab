function ecef = satecef(Oe, Oo, dO, dt, io, xp, yp)
O = Oo + (dO - Oe) * dt;

x = xp * cos(O) - yp * cos(io) * sin(O);
y = xp * sin(O) + yp * cos(io) * cos(O);
z = yp * sin(io);

ecef = [x, y, z];

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "O = %f, x = %f, y = %f, z = %f\n", mod(O, 2*pi), x, y, z);
end
end