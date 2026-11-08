% EXPORT_FIGURES  Run every lab headless and export its figures to results/figures.
%   matlab -batch "addpath('tools'); export_figures"
%   Figures are rendered with the light theme so they read well on GitHub.
%   (A function, not a script: the lab scripts run "clear all" in the base
%   workspace and would wipe a script's variables.)
function export_figures()
root = fileparts(fileparts(mfilename('fullpath')));
run(fullfile(root, 'startup.m'));
outdir = gnss_path('figures');

% {script, lab folder, {figure selector, output file; ...}}
% selector: figure Number (numeric) or figure Name (char)
jobs = {
    'main1', 'lab1_gps_ground_track',      {112, 'lab1_prn18_groundtrack.png'}
    'main2', 'lab2_constellation_iridium', {112, 'lab2_gps_constellation.png'}
    'main3', 'lab2_constellation_iridium', {112, 'lab2_iridium170.png'}
    'main4', 'lab3_visibility_skyplot',    {111, 'lab3_skyplot.png'}
    'main5', 'lab4_dop_ls_positioning',    {'GPS Dilution of Precision (DoP) - 6 Horas', 'lab4_dop_6h.png'}
    'main6', 'lab4_dop_ls_positioning',    {112, 'lab4_ls_convergence_map.png'; ...
                                            'LS Convergence Analysis', 'lab4_ls_convergence_rate.png'}
};

for k = 1:size(jobs, 1)
    script = fullfile(root, 'labs', jobs{k, 2}, [jobs{k, 1} '.m']);
    fprintf('--- %s\n', script);
    evalin('base', sprintf('run(''%s'');', script));
    outputs = jobs{k, 3};
    for j = 1:size(outputs, 1)
        sel = outputs{j, 1};
        if isnumeric(sel)
            f = findobj(groot, 'Type', 'figure', 'Number', sel);
        else
            f = findobj(groot, 'Type', 'figure', 'Name', sel);
        end
        assert(~isempty(f), 'Figure "%s" not found after %s', string(sel), jobs{k, 1});
        f = f(1);
        try theme(f, 'light'); catch, end         % R2025a+ figure themes
        exportgraphics(f, fullfile(outdir, outputs{j, 2}), 'Resolution', 150, ...
                       'BackgroundColor', 'white');
        fprintf('    wrote %s\n', outputs{j, 2});
    end
    close all force;
end
end
