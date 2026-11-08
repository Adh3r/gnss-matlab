% Compute elapsed seconds from last Sunday midnight (GPS time) and download almanac (if necessary)

function esec = gpstime(DD, MM, YYYY, hh, mm, ss)	     % OPTIONAL arguments to override current time (hh must be UTC !)

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
leapseconds = 18;                                   % leap seconds added to UTC since the GPS epoch. Currently (8/9/2025) 18
gpst = JD - gpsepoch + leapseconds / 86400;       % current GPS time in days
gpsw = fix(gpst / 7);                             % current GPS week number
gpstw = gpsw * 7;                                 % GPS time (in days) at week epoch
gtime = 86400 * (gpst - gpstw);                   % elapsed seconds from last week epoch
roll = fix(gpsw / 1024);                            % number of gps week rollovers that have happened (first rollover: 23:59:47 (UTC) 21/8/1999)
gpsw = mod(gpsw, 1024);

fprintf('current GPS week number = %4.0f (%4.0f + %2.0f rolls)\n', gpsw + 1024 * roll, gpsw, roll);
fprintf('elapsed seconds from GPS week epoch until now = %010.3f\n\n', gtime);

% Download current GPS almanac
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%/
limit = 7200;										% obsolescence limit of the ephemeris (secs.)
baseurl = ['https://celestrak.org/GPS/almanac/YUMA/', num2str(YYYY), '/almanac.yuma.week'];
baseweek = gpsw;
esec = gtime;

for(i = 1:10)
   j = mod(i - 1, 7) + 1;
   if (j < i)
      baseweek = gpsw + 1;
      esec = gtime - 7 * 86400;
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
if (~isfile(filename))
   websave(filename, url);                      % download current almanac and store it with filename
end
end
