% GNSS_ROOT  Absolute path of the repository root folder.
function root = gnss_root()
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));   % src/config/ -> repo root
end
