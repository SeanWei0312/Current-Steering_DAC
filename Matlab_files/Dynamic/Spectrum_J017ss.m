clear; clc; close all;

%% ================= SETTINGS =================
csvFile = "DAC_Output_Spectrum_J017ss.csv";

fs_dac = 250e6;      % DAC sampling rate
J = 17;             % coherent input cycles
M = 2048;            % DAC output samples

dcGuardBins   = 2;   % exclude DC bins
fundGuardBins = 2;   % include nearby bins as signal

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

%% ================= CONVERT dB TO POWER WITH ZOH CORRECTION =================
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

%% ================= PRINT RESULTS =================
fprintf("\n========== DAC Dynamic Results ==========\n");
fprintf("CSV file                  : %s\n", csvFile);
fprintf("fs_dac                    : %.3f MHz\n", fs_dac/1e6);
fprintf("J                         : %d\n", J);
fprintf("M                         : %d\n", M);
fprintf("\n");

fprintf("Expected fundamental      : %.6f MHz\n", fin_expected/1e6);
fprintf("Measured fundamental      : %.6f MHz\n", fin_measured/1e6);
fprintf("Fundamental magnitude     : %.2f dB\n", dB_corr(kFund));
fprintf("\n");

fprintf("Largest spur frequency    : %.6f MHz\n", spurFreq/1e6);
fprintf("Largest spur magnitude    : %.2f dB\n", dB_corr(kSpur));
fprintf("Largest spur relative     : %.2f dBc\n", dB_corr(kSpur)-dB_corr(kFund));
fprintf("\n");

fprintf("SFDR                      : %.2f dB\n", SFDR);
fprintf("SNDR                      : %.2f dB\n", SNDR);
fprintf("ENOB                      : %.2f bits\n", ENOB);
fprintf("=========================================\n\n");

%% ================= PLOT SPECTRUM =================
figure;
plot(freq/1e6, dB_corr, 'LineWidth', 1.0);
grid on;
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title(sprintf('DAC Output Spectrum'));

hold on;
plot(fin_measured/1e6, dB_corr(kFund), 'o', ...
    'MarkerSize', 8, 'LineWidth', 1.5);

legend('Spectrum', 'Measured Fundamental', 'Location', 'best');

text(fin_measured/1e6, dB_corr(kFund), ...
    sprintf('  %.3f MHz', fin_measured/1e6), ...
    'VerticalAlignment', 'bottom');