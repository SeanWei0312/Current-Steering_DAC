clear; clc; close all;

%% ================= SETTINGS =================
fs_dac = 250e6;
M = 2048;

J_list = [17 127 251 503 751 997];
corners = ["ss", "tt", "ff"];

dcGuardBins   = 2;
fundGuardBins = 2;

numJ = length(J_list);
numCorners = length(corners);

fin_expected = zeros(numJ, 1);
fin_measured = zeros(numJ, numCorners);

SFDR = zeros(numJ, numCorners);
SNDR = zeros(numJ, numCorners);
ENOB = zeros(numJ, numCorners);

fundMag = zeros(numJ, numCorners);
spurFreq = zeros(numJ, numCorners);
spurMag = zeros(numJ, numCorners);

%% ================= MAIN LOOP =================
for c = 1:numCorners
    corner = char(corners(c));

    for j = 1:numJ
        J = J_list(j);

        csvFile = sprintf('DAC_Output_Spectrum_J%03d%s.csv', J, corner);

        if ~isfile(csvFile)
            error("File not found: %s", csvFile);
        end

        %% ================= LOAD CSV =================
        data = readmatrix(csvFile);

        freq = data(:,1);
        dB_raw = data(:,2);

        valid = isfinite(freq) & isfinite(dB_raw);
        freq = freq(valid);
        dB_raw = dB_raw(valid);

        [freq, idx] = sort(freq);
        dB_raw = dB_raw(idx);

        keep = (freq >= 0) & (freq <= fs_dac/2);
        freq = freq(keep);
        dB_raw = dB_raw(keep);

        N = length(freq);

        %% ================= ZOH CORRECTION =================
        amp = 10.^(dB_raw/20);

        x = freq / fs_dac;
        Hzoh = ones(size(freq));

        nonzero = freq ~= 0;
        Hzoh(nonzero) = abs(sin(pi*x(nonzero)) ./ (pi*x(nonzero)));
        Hzoh(Hzoh < 1e-12) = 1e-12;

        amp_corr = amp ./ Hzoh;
        pwr_spec = amp_corr.^2;
        dB_corr = 20*log10(amp_corr + eps);

        %% ================= FUNDAMENTAL =================
        fin_expected(j) = J/M * fs_dac;

        [~, kFund] = min(abs(freq - fin_expected(j)));
        fin_measured(j,c) = freq(kFund);

        fundBins = max(1, kFund-fundGuardBins) : min(N, kFund+fundGuardBins);
        dcBins = 1:min(N, dcGuardBins+1);

        %% ================= SFDR / SNDR / ENOB =================
        signalPower = sum(pwr_spec(fundBins));

        noiseMask = true(size(freq));
        noiseMask(dcBins) = false;
        noiseMask(fundBins) = false;

        noiseDistPower = sum(pwr_spec(noiseMask));

        SNDR(j,c) = 10*log10(signalPower / noiseDistPower);
        ENOB(j,c) = (SNDR(j,c) - 1.76) / 6.02;

        spurPowerArray = pwr_spec;
        spurPowerArray(~noiseMask) = 0;

        [spurPower, kSpur] = max(spurPowerArray);

        SFDR(j,c) = 10*log10(signalPower / spurPower);

        fundMag(j,c) = dB_corr(kFund);
        spurFreq(j,c) = freq(kSpur);
        spurMag(j,c) = dB_corr(kSpur);
    end
end

%% ================= PRINT RESULTS =================
fprintf("\n========================= DAC DYNAMIC RESULTS =========================\n");
fprintf("fs_dac = %.3f MHz, M = %d\n", fs_dac/1e6, M);
fprintf("=======================================================================\n\n");

for c = 1:numCorners
    corner = char(corners(c));

    fprintf("Corner: %s\n", upper(corner));
    fprintf("%6s %14s %14s %12s %12s %12s %12s %14s\n", ...
        "J", "fin_exp", "fin_meas", "Fund(dB)", ...
        "SFDR(dB)", "SNDR(dB)", "ENOB", "SpurFreq");

    for j = 1:numJ
        fprintf("%6d %14.6f %14.6f %12.2f %12.2f %12.2f %12.2f %14.6f\n", ...
            J_list(j), ...
            fin_expected(j)/1e6, ...
            fin_measured(j,c)/1e6, ...
            fundMag(j,c), ...
            SFDR(j,c), ...
            SNDR(j,c), ...
            ENOB(j,c), ...
            spurFreq(j,c)/1e6);
    end

    fprintf("\n");
end

%% ================= PLOT SFDR =================
figure;
hold on; grid on;

for c = 1:numCorners
    plot(fin_expected/1e6, SFDR(:,c), '-o', ...
        'LineWidth', 1.5, ...
        'MarkerSize', 7, ...
        'DisplayName', upper(corners(c)));
end

yline(48, '--', 'SFDR Requirement = 48 dB', 'LineWidth', 1.2);

xlabel('Input Frequency (MHz)');
ylabel('SFDR (dB)');
title('SFDR vs Input Frequency');
legend('Location', 'best');

%% ================= PLOT SNDR =================
figure;
hold on; grid on;

for c = 1:numCorners
    plot(fin_expected/1e6, SNDR(:,c), '-o', ...
        'LineWidth', 1.5, ...
        'MarkerSize', 7, ...
        'DisplayName', upper(corners(c)));
end

xlabel('Input Frequency (MHz)');
ylabel('SNDR (dB)');
title('SNDR vs Input Frequency');
legend('Location', 'best');

%% ================= PLOT ENOB =================
figure;
hold on; grid on;

for c = 1:numCorners
    plot(fin_expected/1e6, ENOB(:,c), '-o', ...
        'LineWidth', 1.5, ...
        'MarkerSize', 7, ...
        'DisplayName', upper(corners(c)));
end

xlabel('Input Frequency (MHz)');
ylabel('ENOB (bits)');
title('ENOB vs Input Frequency');
legend('Location', 'best');