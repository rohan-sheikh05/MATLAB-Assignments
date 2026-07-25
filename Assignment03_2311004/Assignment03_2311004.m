%Stress-Strain Analysis of W, Al and Pt

clear; clc; close all;


% ## CHANGE THIS PATH to the folder that holds the raw CSV files 
dataDir = 'E:\Study Materials(BUET)\L-2_T-2\Matlab\Assignments\';
outDir  = dataDir;                 % processed CSVs & figure go here as well

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Raw data files :
rawFiles = { ...
    '15680_W_bcc_atoms_1108.5K_[110]_0.005_ps-1_strainrate 1.csv', ...
    '31360_Al_fcc_atoms_746.8K_[110]_0.002_ps-1_strainrate 1.csv', ...
    '32256_Pt_fcc_atoms_1837.35K_[111]_0.02_ps-1_strainrate 1.csv'};

nMat = numel(rawFiles);
matName    = cell(nMat, 1);
strainEng  = cell(nMat, 1);   % engineering strain (dimensionless)
stressEng  = cell(nMat, 1);   % engineering stress (GPa)

%% CLEAN DATA + ADD Load & Displacement :
for k = 1:nMat
    inPath = fullfile(dataDir, rawFiles{k});

    T = cleanTable(inPath);           % drop header-less columns
    T = addLoadDisplacement(T);       % append Load_N & Displacement_angstrom

    [~, baseName] = fileparts(rawFiles{k});
    outPath = fullfile(outDir, [baseName, '_processed.csv']);
    writetable(T, outPath);

    % Engineering stress from the measured area ratio (see notes above)
    Ly0 = T.Ly_angstrom(1);
    Lz0 = T.Lz_angstrom(1);
    areaRatio = (T.Ly_angstrom .* T.Lz_angstrom) ./ (Ly0 * Lz0);

    strainEng{k} = T.strain;
    stressEng{k} = T.normal_stress_GPa .* areaRatio;
    matName{k}   = parseMaterialName(rawFiles{k});
end

%% 
fig = figure('Color', 'w', 'Position', [80 80 1150 820]);
colors = {[0.80 0.10 0.10], [0.10 0.35 0.80], [0.10 0.60 0.20]};

for k = 1:nMat
    subplot(2, 2, k);
    plot(strainEng{k}, stressEng{k}, '-', 'Color', colors{k}, 'LineWidth', 1.2);
    hold on;

    [idxYield, idxUTS, idxFail] = findKeyPoints(strainEng{k}, stressEng{k});

    plot(strainEng{k}(idxYield), stressEng{k}(idxYield), '^', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
    text(strainEng{k}(idxYield), stressEng{k}(idxYield), '  Yield', ...
        'FontSize', 8, 'VerticalAlignment', 'bottom');

    plot(strainEng{k}(idxUTS), stressEng{k}(idxUTS), 'd', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm', 'MarkerSize', 8);
    text(strainEng{k}(idxUTS), stressEng{k}(idxUTS), '  UTS', ...
        'FontSize', 8, 'VerticalAlignment', 'bottom');

    plot(strainEng{k}(idxFail), stressEng{k}(idxFail), 'v', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'c', 'MarkerSize', 8);
    text(strainEng{k}(idxFail), stressEng{k}(idxFail), '  Failure', ...
        'FontSize', 8, 'VerticalAlignment', 'top');

    xlabel('Engineering Strain (-)');
    ylabel('Engineering Stress (GPa)');
    title([matName{k}, ': Stress-Strain Curve']);
    grid on;
    hold off;
end

subplot(2, 2, 4);
hold on;
for k = 1:nMat
    plot(strainEng{k}, stressEng{k}, '-', 'Color', colors{k}, 'LineWidth', 1.2);
end
xlabel('Engineering Strain (-)');
ylabel('Engineering Stress (GPa)');
title('Comparison of Stress-Strain Curves');
legend(matName, 'Location', 'best');
grid on;
hold off;

sgtitle('Engineering Stress-Strain Behaviour of W, Al and Pt (MD Simulation)');

%% 
imgPath = fullfile(outDir, 'StressStrain_Subplots.png');
print(fig, imgPath, '-dpng', '-r300');

%% 
function T = cleanTable(csvPath)


    if ~isfile(csvPath)
        error(['Could not find the file:', newline, csvPath, newline, ...
               'Check that dataDir and the file names in rawFiles are', ...
               ' spelled exactly right (including case) and that the', ...
               ' file is actually in that folder.']);
    end

    fid = fopen(csvPath, 'r');
    headerLine = fgetl(fid);
    fclose(fid);
    headerLine = strrep(headerLine, sprintf('\r'), ''); % strip stray CR

    headerParts = strsplit(headerLine, ',', 'CollapseDelimiters', false);
    isNamed = ~cellfun(@isempty, strtrim(headerParts));

    rawData = readmatrix(csvPath, 'Range', 2);  % numeric data, header skipped
    rawData = rawData(:, isNamed);              % keep named columns only

    varNames = matlab.lang.makeValidName(strtrim(headerParts(isNamed)));
    T = array2table(rawData, 'VariableNames', varNames);
end

function T = addLoadDisplacement(T)
% this Adds Displacement (along the loading axis, Lx) and Load (true stress x
% instantaneous cross-section area) to the cleaned table.

    Lx0 = T.Lx_angstrom(1);
    T.Displacement_angstrom = T.Lx_angstrom - Lx0;

    areaInstant_m2 = (T.Ly_angstrom .* T.Lz_angstrom) * (1e-10)^2;  % Ang^2 -> m^2
    stress_Pa = T.normal_stress_GPa * 1e9;                          % GPa -> Pa
    T.Load_N = stress_Pa .* areaInstant_m2;                         % N
end

function name = parseMaterialName(fname)
% Builds a short "Element (lattice)" label from the raw file name


    tokens = strsplit(fname, '_');
    element = tokens{2};
    lattice = tokens{3};
    name = sprintf('%s (%s)', element, lattice);
end

function [idxYield, idxUTS, idxFail] = findKeyPoints(strain, stress)
% Locates the yield point, UTS and failure point on a (noisy) MD
% stress-strain curve. A light moving-average is used only to make the
% detection robust to thermal noise; the returned indices refer to the
% ORIGINAL (unsmoothed) strain/stress vectors.

    N = numel(stress);
    smoothStress = movmean(stress, 11);

    %  UTS:
    [~, idxUTS] = max(smoothStress);
    utsVal = smoothStress(idxUTS);

    % Yield: 
    elasticMask = strain <= 0.02;
    if nnz(elasticMask) < 5
        elasticMask = false(N, 1);
        elasticMask(1:min(5, N)) = true;
    end
    p = polyfit(strain(elasticMask), smoothStress(elasticMask), 1);
    linearStress = polyval(p, strain);

    deviation = linearStress - smoothStress;              % GPa
    tolerance = 0.02 * utsVal;                             % 2% of UTS
    candidates = find(deviation(1:idxUTS) > tolerance, 1, 'first');
    if isempty(candidates)
        idxYield = idxUTS;
    else
        idxYield = candidates;
    end

    % Failure: stress has dropped to 50% of UTS after the UTS ----
    tail = smoothStress(idxUTS:end);
    candidates = find(tail < 0.5 * utsVal, 1, 'first');
    if isempty(candidates)
        idxFail = N;
    else
        idxFail = idxUTS + candidates - 1;
    end
end
