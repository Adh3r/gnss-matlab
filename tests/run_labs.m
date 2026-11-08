% RUN_LABS  Execute lab entry points headless and write results/logs/mainN.dat.
%   run_labs()            runs main1..main6
%   run_labs({'main5'})   runs a subset
%   Each script is run in the base workspace because the course scripts start
%   with "clear all". Figures are closed after each run.
function run_labs(names)
labs = struct( ...
    'main1', 'lab1_gps_ground_track', ...
    'main2', 'lab2_constellation_iridium', ...
    'main3', 'lab2_constellation_iridium', ...
    'main4', 'lab3_visibility_skyplot', ...
    'main5', 'lab4_dop_ls_positioning', ...
    'main6', 'lab4_dop_ls_positioning');
if nargin < 1
    names = fieldnames(labs)';
end
root = fileparts(fileparts(mfilename('fullpath')));
for k = 1:numel(names)
    script = fullfile(root, 'labs', labs.(names{k}), [names{k} '.m']);
    fprintf('--- running %s\n', script);
    evalin('base', sprintf('run(''%s'');', strrep(script, '''', '''''')));
    close all force;
end
end
