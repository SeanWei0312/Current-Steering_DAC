clear; clc; close all;

%% ================= SETTINGS =================
numBits = 8;
trim_min = 0;
trim_mid = 32;
trim_max = 63;

% If Cadence exports current in A, this code converts to uA automatically.
% If your CSV is already in uA, it keeps it in uA.

Imin_uA = zeros(numBits,1);
Imid_uA = zeros(numBits,1);
Imax_uA = zeros(numBits,1);

lowTune  = zeros(numBits,1);
highTune = zeros(numBits,1);
spanTune = zeros(numBits,1);

%% ================= READ CSV FILES =================
for b = 0:numBits-1

    csvFile = sprintf("Bit%d_Tuning_Range_ss.csv", b);

    if ~isfile(csvFile)
        error("File not found: %s", csvFile);
    end

    data = readmatrix(csvFile);

    % Remove invalid rows
    data = data(all(isfinite(data),2), :);

    % Assume column 1 = trim code, column 2 = current
    trim = data(:,1);
    I = data(:,2);

    % Convert current to positive value
    I = abs(I);

    % Auto unit conversion
    % If current is in A, convert to uA.
    % Example: 60 uA exported as 60e-6 A.
    if max(I) < 1e-2
        I = I * 1e6;   % A -> uA
    end

    % Find nearest trim points
    [~, idx_min] = min(abs(trim - trim_min));
    [~, idx_mid] = min(abs(trim - trim_mid));
    [~, idx_max] = min(abs(trim - trim_max));

    Imin_uA(b+1) = I(idx_min);
    Imid_uA(b+1) = I(idx_mid);
    Imax_uA(b+1) = I(idx_max);

    % Tuning range relative to trim = 32
    lowTune(b+1)  = (Imin_uA(b+1) / Imid_uA(b+1) - 1) * 100;
    highTune(b+1) = (Imax_uA(b+1) / Imid_uA(b+1) - 1) * 100;
    spanTune(b+1) = highTune(b+1) - lowTune(b+1);

end

%% ================= RESULT TABLE =================
bitName = "D" + string(0:numBits-1).';

resultTable = table( ...
    bitName, ...
    Imin_uA, ...
    Imid_uA, ...
    Imax_uA, ...
    lowTune, ...
    highTune, ...
    spanTune, ...
    'VariableNames', { ...
    'Bit', ...
    'Imin_uA_trim0', ...
    'Inom_uA_trim32', ...
    'Imax_uA_trim63', ...
    'Low_Tuning_percent', ...
    'High_Tuning_percent', ...
    'Tuning_Span_percent'});

disp(resultTable);

fprintf("\n========== Average Tuning Range ==========\n");
fprintf("Average low-side tuning  = %.2f %%\n", mean(lowTune));
fprintf("Average high-side tuning = %.2f %%\n", mean(highTune));
fprintf("Average tuning span      = %.2f %%\n", mean(spanTune));
fprintf("==========================================\n");

%% ================= BAR CHART: CURRENT VS BIT =================
currentData = [Imin_uA, Imid_uA, Imax_uA];

figure;
bar(currentData);
grid on;

xlabel("DAC Bit");
ylabel("Current (\muA)");
title("Bit-Weight Tuning Range: Current vs DAC Bit");

xticks(1:numBits);
xticklabels(bitName);

legend( ...
    "Trim = 0, I_{min}", ...
    "Trim = 32, I_{nom}", ...
    "Trim = 63, I_{max}", ...
    "Location", "northwest");

%% ================= BAR CHART: TUNING PERCENTAGE =================
tuningData = [lowTune, highTune];

figure;
bar(tuningData);
grid on;

xlabel("DAC Bit");
ylabel("Tuning Range (%)");
title("Bit-Weight Tuning Range Relative to Trim = 32");

xticks(1:numBits);
xticklabels(bitName);

legend( ...
    "Low tuning", ...
    "High tuning", ...
    "Location", "best");

yline(-10, "--", "-10% Target");
yline(10, "--", "+10% Target");