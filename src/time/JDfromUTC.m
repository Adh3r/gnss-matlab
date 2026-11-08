% Compute Julian Date for a given UTC time and date (algorithm from book of gAGE)

function[JD] = JDfromUTC(HH, mm, ss, DD, MM, YYYY)

if( MM > 2) 
  y = YYYY;
  m = MM;
else
  y = YYYY - 1;
  m = MM + 12;
end

dayfrac = (HH + mm / 60 + ss / 3600) / 24;					% fraction of day
JD = fix(365.25 * y) + fix(30.6001 * (m + 1)) + DD + dayfrac + 1720981.5;

end
