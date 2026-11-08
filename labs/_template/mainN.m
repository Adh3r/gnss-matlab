% MAINN - <short description of the exercise>
% NACC - Lab. session N

clear all;
close all;
run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'startup.m'));   % add src/ to the path

c = gnss_constants();          % c.G, c.Me, c.Oe, c.tol

global fd;                     % debug log consumed by the course-provided functions
fd = fopen(fullfile(gnss_path('logs'), 'mainN.dat'), 'w');

% Fixed epoch (UTC) so that the run is reproducible offline
DD = 14; MM = 10; YYYY = 2026; hh = 12; mm = 0; ss = 0;   % local almanac week 392
[baseweek, esec, NS, Eph] = almanac(DD, MM, YYYY, hh, mm, ss);   % reads/downloads into data/almanacs

% ==== your code goes here ====

fclose(fd);
