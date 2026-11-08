% GNSS_PATH  Absolute path of a well-known project folder (created if missing).
%   p = gnss_path(name) with name one of:
%     'almanacs'     data/almanacs      YUMA almanacs (also the download target)
%     'tle'          data/tle           Two-Line Element sets
%     'measurements' data/measurements  pseudorange files
%     'maps'         data/maps          coastline file for plotworld
%     'logs'         results/logs       debug outputs mainN.dat
%     'figures'      results/figures    exported figures
function p = gnss_path(name)
switch lower(name)
    case {'almanacs', 'tle', 'measurements', 'maps'}
        p = fullfile(gnss_root(), 'data', lower(name));
    case {'logs', 'figures'}
        p = fullfile(gnss_root(), 'results', lower(name));
    otherwise
        error('gnss_path:unknown', 'Unknown project folder "%s".', name);
end
if ~exist(p, 'dir')
    mkdir(p);
end
end
