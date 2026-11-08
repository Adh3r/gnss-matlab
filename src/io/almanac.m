% Compute current time and date and download almanac (if necessary)
function [baseweek, esec, NS, Eph] = almanac(DD, MM, YYYY, hh, mm, ss)	% OPTIONAL arguments to override current time (hh must be UTC !)
ToAlist = [061440, 147456, 233472, 319488, 405504, 503808, 589824];		% list of possible ToA (secs.) within the GPS week according to Celestrak web page
timelapse = 3600;									% time interval in seconds (starting from NOW) for which the almanac should be valid

% Find GPS time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%/
if (nargin == 0)
    unixepoch = 2440587.5;                            % JD at unix epoch: 0h (UTC) 1/1/1970
    ntime = clock();								  % Matlab and clock() give local time
    YYYY = ntime(1);
    unixmillis = java.lang.System.currentTimeMillis;  % milliseconds from unix epoch
    JD = unixepoch + unixmillis / 1000 / 86400;       % Julian Date now in UTC
else
    JD = JDfromUTC(hh, mm, ss, DD, MM, YYYY);         % OVERRIDE CURRENT TIME
end

gpsepoch = 2444244.5;                               % JD at GPS epoch: 0h (UTC) 6/1/1980
leapseconds = 18;                                   % leap seconds added to UTC since the GPS epoch
gpst = JD - gpsepoch + leapseconds / 86400;         % GPS time
gpsw = fix(gpst / 7);                               % GPS week
gpstw = gpsw * 7;                                   % GPS time (in days) at week epoch
gpstime = 86400 * (gpst - gpstw);                   % elapsed seconds from last week epoch
roll = fix(gpsw / 1024);                            % number of gps week rollovers
gpsw = mod(gpsw, 1024);
fprintf('GPS week number = %4.0f (%4.0f + %2.0f rolls)\n', gpsw + 1024 * roll, gpsw, roll);
fprintf('elapsed seconds from GPS week epoch = %010.3f\n', gpstime);

% Download current GPS almanac
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%/
limit = 7200;										% obsolescence limit of the ephemeris (secs.)
baseurl = ['https://celestrak.org/GPS/almanac/YUMA/', num2str(YYYY), '/almanac.yuma.week'];
baseweek = gpsw;
esec = gpstime;

for(i = 1:10)
   j = mod(i - 1, 7) + 1;
   if (j < i)
      baseweek = gpsw + 1;
      esec = gpstime - 7 * 86400;
   end
   if (esec + timelapse >= ToAlist(j) + limit)
      continue
   else
      sufix = sprintf('%04.0f.%06.0f', baseweek, ToAlist(j));
      break
   end
end

url = [baseurl sufix '.txt'];					% build complete URL to download almanac
filename = fullfile(gnss_path('almanacs'), ['almanac_week_' sufix '.txt']);	% local almanac store (data/almanacs)

if (~isfile(filename))                          % download only if not already stored
   try
       websave(filename, url);                  % Intentar función moderna websave (HTTPS)
   catch
       try
           urlwrite(url, filename);             % Compatibilidad con versiones antiguas
       catch
           error(['No se pudo descargar el almanaque desde Celestrak (%s).\n', ...
                  'Asegúrate de tener conexión o de usar una fecha con un almanaque local existente.'], url);
       end
   end
end

fid = fopen(filename, 'r');						% read ephemeris from almanac
if (fid == -1)
    error('Error al abrir el fichero de almanaque local: %s', filename);
end

NS = 0;
while (true)
  [~, count] = fscanf(fid, '%c', 45);		% read label
  if (count == 0) break; end;
  for (i = 1:13)
    fscanf(fid, '%c', 25);
    [Eph(NS + 1, i), count] = fscanf(fid, '%f');
  end
  if (Eph(NS + 1, 2) == 0) NS = NS + 1; end;
end
fclose(fid);
end