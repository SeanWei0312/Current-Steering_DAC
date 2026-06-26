clear; clc; close all;

%% ================= SETTINGS =================
fs_dac = 250e6;      % DAC sampling rate
M = 2048;            % DAC output samples

J_list = [17 127 251 503 751 997];

csvFiles = [
    "DAC_Output_Spectrum_J017tt.csv"
    "DAC_Output_Spectrum_J127tt.csv"
    "DAC_Output_Spectrum_J251tt.csv"
    "DAC_Output_Spectrum_J503tt.csv"
    "DAC_Output_Spectrum_J751tt.csv"
    "DAC_Output_Spectrum_J997tt.csv"
];

dcGuardBins   = 2;
fundGuardBins = 2;

numFiles = length(csvFiles);

fin_expected_list = zeros(numFiles,1);
fin_measured_list = zeros(numFiles,1);
SFDR_list = zeros(numFiles,1);
SNDR_list = zeros(numFiles,1);
ENOB_list = zeros(numFiles,1);
fundMag_list = zeros(numFiles,1);
spurFreq_list = zeros(numFiles,1);
spurMag_list = zeros(numFiles,1);

%% ================= MAIN LOOP =================
figure;
hold on;
grid on;
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('DAC Output Spectrum, tt Corner');

for n = 1:numFiles

    %% ================= LOAD CSV =================
    csvFile = csvFiles(n);
    J = J_list(n);

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

    %% ================= FIND FUNDAMENTAL =================
    fin_expected = J/M * fs_dac;

    [~, kFund] = min(abs(freq - fin_expected));
    fin_measured = freq(kFund);

    fundBins = max(1, kFund-fundGuardBins) : min(N, kFund+fundGuardBins);
    dcBins = 1:min(N, dcGuardBins+1);

    %% ================= CALCULATE SFDR, SNDR, ENOB =================
    signalPower = sum(pwr_spec(fundBins));

    noiseMask = true(size(freq));
    noiseMask(dcBins) = false;
    noiseMask(fundBins) = false;

    noiseDistPower = sum(pwr_spec(noiseMask));

    SNDR = 10*log10(signalPower / noiseDistPower);
    ENOB = (SNDR - 1.76) / 6.02;

    spurPowerArray = pwr_spec;
    spurPowerArray(~noiseMask) = 0;

    [spurPower, kSpur] = max(spurPowerArray);
    spurFreq = freq(kSpur);

    SFDR = 10*log10(signalPower / spurPower);

    %% ================= SAVE RESULTS =================
    fin_expected_list(n) = fin_expected;
    fin_measured_list(n) = fin_measured;
    SFDR_list(n) = SFDR;
    SNDR_list(n) = SNDR;
    ENOB_list(n) = ENOB;
    fundMag_list(n) = dB_corr(kFund);
    spurFreq_list(n) = spurFreq;
    spurMag_list(n) = dB_corr(kSpur);

    %% ================= PLOT SPECTRUM =================
    plot(freq/1e6, dB_corr, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('J = %d, fin = %.2f MHz', J, fin_measured/1e6));

    plot(fin_measured/1e6, dB_corr(kFund), 'o', ...
        'MarkerSize', 7, 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');

end

legend('Location', 'best');

%% ================= PRINT RESULTS TABLE =================
fprintf("\n========================= tt CORNER DYNAMIC RESULTS =========================\n");
fprintf("fs_dac = %.3f MHz, M = %d\n\n", fs_dac/1e6, M);

fprintf("%6s %18s %18s %12s %12s %12s %12s %18s\n", ...
    "J", "fin_exp(MHz)", "fin_meas(MHz)", "Fund(dB)", ...
    "SFDR(dB)", "SNDR(dB)", "ENOB", "SpurFreq(MHz)");

for n = 1:numFiles
    fprintf("%6d %18.6f %18.6f %12.2f %12.2f %12.2f %12.2f %18.6f\n", ...
        J_list(n), ...
        fin_expected_list(n)/1e6, ...
        fin_measured_list(n)/1e6, ...
        fundMag_list(n), ...
        SFDR_list(n), ...
        SNDR_list(n), ...
        ENOB_list(n), ...
        spurFreq_list(n)/1e6);
end

fprintf("============================================================================\n\n");

%% ================= PLOT SFDR AND SNDR VS INPUT FREQUENCY =================
figure;
plot(fin_measured_list/1e6, SFDR_list, '-o', 'LineWidth', 1.5, 'MarkerSize', 7);
hold on;
plot(fin_measured_list/1e6, SNDR_list, '-s', 'LineWidth', 1.5, 'MarkerSize', 7);
grid on;

xlabel('Input Frequency (MHz)');
ylabel('Dynamic Performance (dB)');
title('tt Corner: SFDR and SNDR vs Input Frequency');
legend('SFDR', 'SNDR', 'Location', 'best');

yline(48, '--', 'SFDR Requirement = 48 dB', 'LineWidth', 1.2);

%% ================= PLOT ENOB VS INPUT FREQUENCY =================
figure;
plot(fin_measured_list/1e6, ENOB_list, '-o', 'LineWidth', 1.5, 'MarkerSize', 7);
grid on;

xlabel('Input Frequency (MHz)');
ylabel('ENOB (bits)');
title('tt Corner: ENOB vs Input Frequency');