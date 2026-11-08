% Result is in radians
% from https://astrogreg.com/snippets/greenwichMeanSiderealTime.html
% The IAU Resolutions on Astronomical Reference Systems, Time Scales, and Earth Rotation Models Explanation and Implementation (George H. Kaplan)
% https://arxiv.org/pdf/astro-ph/0602086.pdf
function gmst = greenwichMeanSiderealTime(jd_ut1)
  t = (jd_ut1 - 2451545.0) / 36525.0;
  era = earthRotationAngle(jd_ut1);
  gmst = mod(era + (0.014506 + 4612.15739966 * t + 1.39667721 * t^2 - 0.00009344 * t^3 + 0.00001882 * t^4) / 60 / 60 * pi / 180, 2 * pi);
  if (gmst < 0) gmst = gmst + 2 * pi; end
end
