function era = earthRotationAngle(jd_ut1)
  t = jd_ut1 - 2451545.0;
  frac = mod(jd_ut1, 1);    
  era = mod(pi * 2 * (0.7790572732640 + 0.00273781191135448 * t + frac), 2 * pi);
  if (era < 0) era = era + 2 * pi; end
end