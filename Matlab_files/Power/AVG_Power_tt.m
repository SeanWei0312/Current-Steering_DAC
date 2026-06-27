clear; clc; close all;

%% ================= SETTINGS =================
t1 = 10e-9;      % 10 ns
t2 = 990e-9;     % 990 ns

freqLabel = ["Low J017", "Mid J503", "High J997"];

files.Retimer = [
    "Power_Retimer_J017tt.csv"
    "Power_Retimer_J503tt.csv"
    "Power_Retimer_J997tt.csv"
];

files.Bias = [
    "Power_Bias_J017tt.csv"
    "Power_Bias_J503tt.csv"
    "Power_Bias_J997tt.csv"
];

files.DAC_Load = [
    "Power_DAC_Load_J017tt.csv"
    "Power_DAC_Load_J503tt.csv"
    "Power_DAC_Load_J997tt.csv"
];

%% ================= CALCULATE AVG POWER =================
numFreq = 3;

Pavg_Retimer  = zeros(numFreq,1);
Pavg_Bias     = zeros(numFreq,1);
Pavg_DAC_Load = zeros(numFreq,1);
Pavg_Total    = zeros(numFreq,1);

for k = 1:numFreq
    Pavg_Retimer(k)  = calc_avg_power(files.Retimer(k),  t1, t2);
    Pavg_Bias(k)     = calc_avg_power(files.Bias(k),     t1, t2);
    Pavg_DAC_Load(k) = calc_avg_power(files.DAC_Load(k), t1, t2);

    Pavg_Total(k) = Pavg_Retimer(k) + Pavg_Bias(k) + Pavg_DAC_Load(k);
end

%% ================= PRINT RESULTS =================
fprintf('\n================ DAC POWER RESULTS ================\n');
fprintf('Average window: %.1f ns to %.1f ns\n', t1*1e9, t2*1e9);
fprintf('Corner        : TT\n');
fprintf('Unit          : mW\n');
fprintf('===================================================\n');
fprintf('%-12s %12s %12s %14s %12s\n', ...
    'Freq', 'Retimer', 'Bias', 'DAC+Load', 'Total');

for k = 1:numFreq
    fprintf('%-12s %12.6f %12.6f %14.6f %12.6f\n', ...
        freqLabel(k), ...
        Pavg_Retimer(k)*1e3, ...
        Pavg_Bias(k)*1e3, ...
        Pavg_DAC_Load(k)*1e3, ...
        Pavg_Total(k)*1e3);
end

fprintf('===================================================\n\n');

%% ================= PLOT COMPARISON =================
P_mW = [
    Pavg_Retimer, ...
    Pavg_Bias, ...
    Pavg_DAC_Load, ...
    Pavg_Total
] * 1e3;

figure;
bar(P_mW);
grid on;

set(gca, 'XTickLabel', freqLabel);
ylabel('Average Power (mW)');
title('Average Power Comparison from 10 ns to 1 us');

legend('Retimer', 'Bias', 'DAC + Load', 'Total', ...
       'Location', 'northwest');

%% ================= LOCAL FUNCTION =================
function Pavg = calc_avg_power(csvFile, t1, t2)

    if ~isfile(csvFile)
        error("File not found: %s", csvFile);
    end

    data = readmatrix(csvFile);

    % Remove empty rows
    data = data(all(isfinite(data), 2), :);

    if size(data,2) < 2
        error("CSV file must have at least two columns: time and power. File: %s", csvFile);
    end

    t = data(:,1);
    p = data(:,2);

    % Sort by time
    [t, idx] = sort(t);
    p = p(idx);

    % Remove duplicate time points
    [t, uniqueIdx] = unique(t, 'stable');
    p = p(uniqueIdx);

    if t1 < min(t) || t2 > max(t)
        error("Average window is outside data range in %s", csvFile);
    end

    % Interpolate exact endpoints
    p1 = interp1(t, p, t1, 'linear');
    p2 = interp1(t, p, t2, 'linear');

    keep = (t > t1) & (t < t2);

    t_win = [t1; t(keep); t2];
    p_win = [p1; p(keep); p2];

    % Time-average power
    Pavg = trapz(t_win, p_win) / (t2 - t1);
end