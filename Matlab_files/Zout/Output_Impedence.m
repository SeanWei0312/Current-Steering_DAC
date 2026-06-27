clear; clc; close all;

%% ============================================================
%  DAC Zout Analysis vs Input Code
%  Files:
%     Zout_diff_tt.csv
%     Zout_cm_tt.csv
%
%  Log:
%     average / min / max / peak-to-peak / percent variation
%
%  Plots:
%     1. DAC Differential Output Impedance vs Code @ 1 Hz
%     2. DAC Common-Mode Output Impedance vs Code @ 1 Hz
%     3. DAC Zoutdiff and Zoutcm vs Code @ 1 Hz
%     4. Zoutdiff vs Frequency for Selected Codes
%     5. Zoutcm vs Frequency for Selected Codes
%% ============================================================

diffFile = "Zout_diff_tt.csv";
cmFile   = "Zout_cm_tt.csv";

fPick = 1;   % Hz

selectedCodes = [0 64 128 192 255];

%% ================= LOAD DATA =================
[freqDiff, codesDiff, Zdiff] = load_zout_csv(diffFile);
[freqCM,   codesCM,   Zcm]   = load_zout_csv(cmFile);

%% ================= KEEP ONLY CODE 0~255 =================
keepDiff = codesDiff >= 0 & codesDiff <= 255;
keepCM   = codesCM   >= 0 & codesCM   <= 255;

codesDiff = codesDiff(keepDiff);
Zdiff     = Zdiff(:, keepDiff);

codesCM = codesCM(keepCM);
Zcm     = Zcm(:, keepCM);

%% ================= SORT BY CODE =================
[codesDiff, idxD] = sort(codesDiff);
Zdiff = Zdiff(:, idxD);

[codesCM, idxC] = sort(codesCM);
Zcm = Zcm(:, idxC);

if ~isequal(codesDiff, codesCM)
    error("Diff and CM files do not have the same code list.");
end

codes = codesDiff;

%% ================= PICK FREQUENCY POINT =================
[~, idxFD] = min(abs(freqDiff - fPick));
[~, idxFC] = min(abs(freqCM   - fPick));

fUseDiff = freqDiff(idxFD);
fUseCM   = freqCM(idxFC);

Zdiff_at_f = Zdiff(idxFD, :);
Zcm_at_f   = Zcm(idxFC, :);

%% ================= CALCULATE SUMMARY =================
avg_Zdiff = mean(Zdiff_at_f, 'omitnan');
avg_Zcm   = mean(Zcm_at_f,   'omitnan');

[min_Zdiff, minIdxD] = min(Zdiff_at_f);
[max_Zdiff, maxIdxD] = max(Zdiff_at_f);

[min_Zcm, minIdxC] = min(Zcm_at_f);
[max_Zcm, maxIdxC] = max(Zcm_at_f);

ptp_Zdiff = max_Zdiff - min_Zdiff;
ptp_Zcm   = max_Zcm   - min_Zcm;

pct_Zdiff = 100 * ptp_Zdiff / avg_Zdiff;
pct_Zcm   = 100 * ptp_Zcm   / avg_Zcm;

%% ================= LOG ONLY =================
fprintf('\n========== DAC Zout Analysis ==========\n');
fprintf('Diff file                 : %s\n', diffFile);
fprintf('CM file                   : %s\n', cmFile);
fprintf('Requested frequency        : %.6g Hz\n', fPick);
fprintf('Used Zoutdiff frequency    : %.6g Hz\n', fUseDiff);
fprintf('Used Zoutcm frequency      : %.6g Hz\n', fUseCM);
fprintf('Number of codes            : %d\n', length(codes));

fprintf('\n----- Zoutdiff vs Code -----\n');
fprintf('Average Zoutdiff           : %.6f ohm\n', avg_Zdiff);
fprintf('Minimum Zoutdiff           : %.6f ohm at code %d\n', ...
    min_Zdiff, codes(minIdxD));
fprintf('Maximum Zoutdiff           : %.6f ohm at code %d\n', ...
    max_Zdiff, codes(maxIdxD));
fprintf('Peak-to-peak variation     : %.6f ohm\n', ptp_Zdiff);
fprintf('Percent variation          : %.4f %%\n', pct_Zdiff);

fprintf('\n----- Zoutcm vs Code -----\n');
fprintf('Average Zoutcm             : %.6f ohm\n', avg_Zcm);
fprintf('Minimum Zoutcm             : %.6f ohm at code %d\n', ...
    min_Zcm, codes(minIdxC));
fprintf('Maximum Zoutcm             : %.6f ohm at code %d\n', ...
    max_Zcm, codes(maxIdxC));
fprintf('Peak-to-peak variation     : %.6f ohm\n', ptp_Zcm);
fprintf('Percent variation          : %.4f %%\n', pct_Zcm);

fprintf('=======================================\n\n');

%% ================= PLOT 1: Zoutdiff vs Code =================
figure;
plot(codes, Zdiff_at_f, 'LineWidth', 1.8);
grid on;
xlabel('Input Code');
ylabel('Zoutdiff (\Omega)');
title(sprintf('DAC Differential Output Impedance vs Code @ %.6g Hz', fUseDiff));
xlim([0 255]);

%% ================= PLOT 2: Zoutcm vs Code =================
figure;
plot(codes, Zcm_at_f, 'LineWidth', 1.8);
grid on;
xlabel('Input Code');
ylabel('Zoutcm (\Omega)');
title(sprintf('DAC Common-Mode Output Impedance vs Code @ %.6g Hz', fUseCM));
xlim([0 255]);

%% ================= PLOT 3: Zoutdiff and Zoutcm vs Code =================
figure;
plot(codes, Zdiff_at_f, 'LineWidth', 1.8); hold on;
plot(codes, Zcm_at_f, '--', 'LineWidth', 1.8);
grid on;
xlabel('Input Code');
ylabel('Output Impedance (\Omega)');
title(sprintf('DAC Zoutdiff and Zoutcm vs Code @ %.6g Hz', fUseDiff));
legend('Zoutdiff', 'Zoutcm', 'Location', 'best');
xlim([0 255]);

%% ================= PLOT 4: Zoutdiff vs Frequency for Selected Codes =================
figure; hold on;

legendDiff = strings(0);

for k = 1:length(selectedCodes)
    codeNow = selectedCodes(k);
    idxCode = find(codes == codeNow, 1);

    if ~isempty(idxCode)
        semilogx(freqDiff, Zdiff(:, idxCode), 'LineWidth', 1.5);
        legendDiff(end+1) = "Code " + string(codeNow);
    end
end

grid on;
xlabel('Frequency (Hz)');
ylabel('Zoutdiff (\Omega)');
title('Zoutdiff vs Frequency for Selected Codes');
legend(legendDiff, 'Location', 'best');

%% ================= PLOT 5: Zoutcm vs Frequency for Selected Codes =================
figure; hold on;

legendCM = strings(0);

for k = 1:length(selectedCodes)
    codeNow = selectedCodes(k);
    idxCode = find(codes == codeNow, 1);

    if ~isempty(idxCode)
        semilogx(freqCM, Zcm(:, idxCode), 'LineWidth', 1.5);
        legendCM(end+1) = "Code " + string(codeNow);
    end
end

grid on;
xlabel('Frequency (Hz)');
ylabel('Zoutcm (\Omega)');
title('Zoutcm vs Frequency for Selected Codes');
legend(legendCM, 'Location', 'best');

%% ============================================================
%  Local Function
%% ============================================================
function [freq, codes, Zmat] = load_zout_csv(filename)

    T = readtable(filename, 'VariableNamingRule', 'preserve');
    varNames = string(T.Properties.VariableNames);

    codes = [];
    xCols = [];
    yCols = [];

    for i = 1:length(varNames)
        name = varNames(i);

        if contains(name, "code=") && endsWith(strtrim(name), "X")
            token = regexp(name, 'code=(\d+)', 'tokens');

            if ~isempty(token)
                codeNow = str2double(token{1}{1});

                yName = replace(name, " X", " Y");
                yIdx = find(varNames == yName, 1);

                if ~isempty(yIdx)
                    codes(end+1) = codeNow;
                    xCols(end+1) = i;
                    yCols(end+1) = yIdx;
                end
            end
        end
    end

    if isempty(codes)
        error("No code-based X/Y columns found in file: %s", filename);
    end

    % Sort columns by input code
    [codes, idx] = sort(codes);
    xCols = xCols(idx);
    yCols = yCols(idx);

    % Use first X column as frequency vector
    freq = T{:, xCols(1)};

    % Build Z matrix: rows = frequency, columns = code
    Zmat = zeros(height(T), length(codes));

    for k = 1:length(codes)
        freq_k = T{:, xCols(k)};
        Z_k    = T{:, yCols(k)};

        % If frequency grid is not exactly the same, interpolate to first grid
        if length(freq_k) ~= length(freq) || ...
           any(abs(freq_k - freq) > 1e-9 * max(1, max(abs(freq))))
            Zmat(:, k) = interp1(freq_k, Z_k, freq, 'linear', 'extrap');
        else
            Zmat(:, k) = Z_k;
        end
    end
end