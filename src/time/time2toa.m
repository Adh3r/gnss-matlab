% Computes elapsed time to/from target time (DD, MM, YYYY, hh, mm, ss) to ToA [s]
% and GAST [deg] at ToA. ToA must be given in days of current year
% If called with a single argument (ToA) the target date is current time
% dt = elapsed time [s] from ToA (negative if ToA is in the future)
% GAST = Greenwich Mean Sidereal Time [deg] at ToA

function [dt, GAST] = time2toa(ToA, DD, MM, YYYY, hh, mm, ss)   % OPTIONAL arguments to override current time (hh must be UTC !)

    if (nargin == 1)
        % target time is now: Find Julian Date now
        unixepoch = 2440587.5;                                % JD at unix epoch: 0h (UTC) 1/1/1970
        unixmillis = java.lang.System.currentTimeMillis;      % milliseconds from unix epoch
        JD = unixepoch + unixmillis / 1000 / 86400;           % Julian Date now in UTC
        ntime = clock();								      % Matlab and clock() give local time
        YYYY = ntime(1);                                      % get current year (matlab)
    else
        % OVERRIDE CURRENT TIME: Find Julian Date at target time
        JD = JDfromUTC(hh, mm, ss, DD, MM, YYYY);             % Julian Date at target time
    end
    
    % Compute target time offset (in [s]) from ToA
    JDYY = JDfromUTC(0, 0, 0, 1, 1, YYYY);                    % Julian Date at 00:00 UTC of 1/1/YYYY
    JToA = JDYY + ToA - 1;                                    % ToA in JD
    dt = 86400 * (JD - JToA);                                 % elapsed time from ToA [s]
    % [HH, mm, ss, secfrac, ~, DD, MM, YYYY] = UTCfromJD(JToA); % UTC time and date of ToA
    % toadate = date+time string corresponding to the ToA
    % toadate = sprintf(" %02.0f/%02.0f/%4.0f, %02.0f:%02.0f:%02.0f UTC\n", DD, MM, YYYY, HH, mm, round(ss+secfrac));
    
    % Greenwich Mean Sidereal Time (GMST) is the hour angle of the average position of the vernal equinox,
    % neglecting short term motions of the equinox due to nutation. GAST is GMST corrected for
    % the shift in the position of the vernal equinox due to nutation.
    % GAST at a given epoch is the RA of the Greenwich meridian at that epoch (usually in time units).
    
    % Find GAST in degrees at ToA
    GAST = greenwichMeanSiderealTime(JToA);
    GAST = GAST * 180 / pi;

end
