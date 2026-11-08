% GNSS_CONSTANTS  Physical constants shared by all labs.
%   c = gnss_constants() returns a struct with fields
%     G   universal gravitational constant [m^3 kg^-1 s^-2]
%     Me  mass of the Earth [kg]
%     Oe  Earth rotation rate [rad/s] (WGS-84)
%     tol convergence tolerance for Kepler's equation [rad]
%   Lab scripts keep their own literal values (as required by the course);
%   new labs should use this function.
function c = gnss_constants()
c.G   = 6.67384e-11;
c.Me  = 5.972e+24;
c.Oe  = 7.2921151467e-5;
c.tol = 1.e-8;
end
