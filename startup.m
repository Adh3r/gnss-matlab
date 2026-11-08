% STARTUP  Add the GNSS library (src/ and its subfolders) to the MATLAB path.
%   Run once per session from the repository root, or let any lab script call
%   it automatically. Safe to call repeatedly. (No variables are created, so it
%   can also be run from functions with nested functions, e.g. main4.)

addpath(genpath(fullfile(fileparts(mfilename('fullpath')), 'src')));
