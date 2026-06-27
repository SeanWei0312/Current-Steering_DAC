clear; clc; close all;

%% ================= SETTINGS =================
corners = ["ss", "tt", "ff"];
bits = 0:7;

trim_min = 0;
trim_mid = 32;
trim_max = 63;

% CSV format assumption:
% column 1 = trim code
% column 2 = measured current
%
% If your CSV current is exported in A, use "A".
% If your CSV current is exported in uA, use "uA".
% If your CSV current is exported in mA, use "mA".
current_unit = "A";

%% ================= STORAGE =================
numCorners = length(corners);
numBits = length(bits);

Imin_mA = zeros(numBits, numCorners);
Imid_mA = zeros(numBits, numCorners);
Imax_mA = zeros(numBits, numCorners);

low_pct  = zeros(numBits, numCorners);
high_pct = zeros(numBits, numCorners);

%% ================= READ FILES =================
for c = 1:numCorners
    corner = corners(c);

    for b = 1:numBits
        bit = bits(b);

        csvFile = sprintf("Bit%d_Tuning_Range_%s.csv", bit, corner);

        if ~isfile(csvFile)
            error("File not found: %s", csvFile);
        end

        data = readmatrix(csvFile);

        % Remove invalid rows
        data = data(all(isfinite(data), 2), :);

        trim = data(:,1);
        Iraw = data(:,2);

        % Sort by trim code
        [trim, idx] = sort(trim);
        Iraw = Iraw(idx);

        % Use absolute current because Cadence current sign may be negative
        Iraw = abs(Iraw);

        % Convert current to mA
        switch current_unit
            case "A"
                I_mA = Iraw * 1e3;
            case "uA"
                I_mA = Iraw * 1e-3;
            case "mA"
                I_mA = Iraw;
            otherwise
                error("Unsupported current_unit. Use A, uA, or mA.");
        end

        % Pick current at trim = 0, 32, 63
        Imin_mA(b,c) = value_at_trim(trim, I_mA, trim_min);
        Imid_mA(b,c) = value_at_trim(trim, I_mA, trim_mid);
        Imax_mA(b,c) = value_at_trim(trim, I_mA, trim_max);

        % Calculate tuning percentage relative to trim = 32
        low_pct(b,c)  = (Imin_mA(b,c) / Imid_mA(b,c) - 1) * 100;
        high_pct(b,c) = (Imax_mA(b,c) / Imid_mA(b,c) - 1) * 100;
    end
end

%% ================= AVERAGE OVER 8 BITS =================
avg_Imin_mA = mean(Imin_mA, 1);
avg_Imid_mA = mean(Imid_mA, 1);
avg_Imax_mA = mean(Imax_mA, 1);

avg_low_pct  = mean(low_pct, 1);
avg_high_pct = mean(high_pct, 1);

% Plot all positive percentage values
avg_low_pct_pos  = abs(avg_low_pct);
avg_high_pct_pos = abs(avg_high_pct);

%% ================= SUMMARY TABLE =================
summaryTable = table( ...
    corners(:), ...
    avg_Imin_mA(:), ...
    avg_Imid_mA(:), ...
    avg_Imax_mA(:), ...
    avg_low_pct(:), ...
    avg_high_pct(:), ...
    avg_low_pct_pos(:), ...
    avg_high_pct_pos(:), ...
    'VariableNames', { ...
    'Corner', ...
    'Avg_Imin_mA', ...
    'Avg_Imid_mA', ...
    'Avg_Imax_mA', ...
    'Avg_Low_Tuning_pct', ...
    'Avg_High_Tuning_pct', ...
    'Avg_Low_Tuning_Positive_pct', ...
    'Avg_High_Tuning_Positive_pct'});

disp(summaryTable);

%% ================= PLOT 1: CURRENT BAR CHART =================
figure;

current_bar_data = [avg_Imin_mA(:), avg_Imid_mA(:), avg_Imax_mA(:)];

bar(current_bar_data);
grid on;

set(gca, 'XTickLabel', corners);
xlabel("Process Corner");
ylabel("Average Current (mA)");
title("Average Bit-Weight Current vs Process Corner");

legend("I_{min} @ trim=0", ...
       "I_{mid} @ trim=32", ...
       "I_{max} @ trim=63", ...
       "Location", "northwest");

%% ================= PLOT 2: TUNING PERCENT BAR CHART =================
figure;

tuning_bar_data = [avg_low_pct_pos(:), avg_high_pct_pos(:)];

bar(tuning_bar_data);
grid on;

set(gca, 'XTickLabel', corners);
xlabel("Process Corner");
ylabel("Average Tuning Range Magnitude (%)");
title("Average Bit-Weight Tuning Range vs Process Corner");

legend("|Low tuning|", ...
       "High tuning", ...
       "Location", "northwest");

%% ================= HELPER FUNCTION =================
function val = value_at_trim(trim, y, target_trim)
    [~, idx] = min(abs(trim - target_trim));
    val = y(idx);
end