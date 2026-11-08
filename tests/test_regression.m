% TEST_REGRESSION  Compare results/logs/mainN.dat against tests/baselines/.
%   Baselines were produced by the ORIGINAL per-lab folders (Practica_1..4)
%   before the repository was reorganised. Run tests/run_labs.m first.
%     results = runtests('tests');
function tests = test_regression
tests = functiontests(localfunctions);
end

function testMain1(tc), compareLog(tc, 'main1', 1.5e-6, true); end   % absolute: last printed digit
function testMain2(tc), compareLog(tc, 'main2', 1e-9); end
function testMain3(tc), compareLog(tc, 'main3', 1e-9); end
function testMain4(tc), compareLog(tc, 'main4', 1e-9); end
function testMain5(tc), compareLog(tc, 'main5', 1e-9); end
function testMain6(tc), compareLog(tc, 'main6', 1e-9); end

function testMain6Solution(tc)
txt = fileread(logFile('main6'));
verifySubstring(tc, txt, 'Number of iterations = 5');
verifySubstring(tc, txt, 'Computed LLA = -75.928405 -20.635823 3.999894');
end

function testMain5FirstEpochDop(tc)
txt = fileread(logFile('main5'));
first = regexp(txt, 'gdop = [^\n]*', 'match', 'once');
verifyEqual(tc, first, ...
    'gdop = 2.345388, pdop = 2.018470, hdop = 1.046588, vdop = 1.725942, tdop = 1.194413');
end

function testMain4VisibleSatellites(tc)
txt = fileread(logFile('main4'));
block = extractAfter(txt, sprintf('\nVisible satellites:\n'));
tok = regexp(block, 'prn = (\d+)', 'tokens');
prn = cellfun(@(c) str2double(c{1}), tok);
verifyEqual(tc, prn, [5 14 15 18 20 21 22 24 30]);
end

% ------------------------------------------------------------------ helpers
function f = logFile(name)
f = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'results', 'logs', [name '.dat']);
end

function compareLog(tc, name, tol, absolute)
if nargin < 4, absolute = false; end
base = fullfile(fileparts(mfilename('fullpath')), 'baselines', [name '.dat']);
new  = logFile(name);
assumeTrue(tc, isfile(new), sprintf('%s missing: run tests/run_labs first', new));
a = readLines(base);
b = readLines(new);
if strcmp(name, 'main1')
    % main1 now uses the closed-form ecef2lla (labs 2-4), which logs an
    % extra "lat = .., long = .., alt = .." line per call; the original lab-1
    % variant (ecef2lla_bowring) did not.
    b = b(~startsWith(b, 'lat = '));
end
verifyEqual(tc, numel(b), numel(a), sprintf('%s: number of lines', name));
if numel(a) ~= numel(b), return; end
for i = 1:numel(a)
    na = numbersIn(a{i});
    nb = numbersIn(b{i});
    textA = regexprep(a{i}, '[-+]?\d+(\.\d+)?([eE][-+]?\d+)?', '#');
    textB = regexprep(b{i}, '[-+]?\d+(\.\d+)?([eE][-+]?\d+)?', '#');
    if ~strcmp(textA, textB) || numel(na) ~= numel(nb) || ...
            any(abs(na - nb) > tol * max(1, ~absolute * abs(na)))
        verifyFail(tc, sprintf('%s line %d differs:\n  baseline: %s\n  new:      %s', ...
            name, i, a{i}, b{i}));
        return
    end
end
end

function lines = readLines(f)
lines = splitlines(string(fileread(f)));
lines = cellstr(lines(strlength(strtrim(lines)) > 0));
end

function v = numbersIn(s)
v = str2double(regexp(s, '[-+]?\d+(\.\d+)?([eE][-+]?\d+)?', 'match'));
end
