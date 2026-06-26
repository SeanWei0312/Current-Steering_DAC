clear; clc; close all;

%% ============================================================
%  DAC Output Report Plots
%
%  Required CSV files:
%  Vcm_ff.csv,   Vcm_tt.csv,   Vcm_ss.csv
%  Voutp_ff.csv, Voutp_tt.csv, Voutp_ss.csv
%  Voutn_ff.csv, Voutn_tt.csv, Voutn_ss.csv
%  Vdiff_ff.csv, Vdiff_tt.csv, Vdiff_ss.csv
%
%  Each CSV:
%  Column 1 = time
%  Column 2 = voltage
%% ============================================================

corners = ["ss", "tt", "ff"];

% Ignore initial transient if needed
% Example: t_ignore = 20e-9;
t_ignore = 0;

%% ===================== READ DATA =====================
for c = 1:length(corners)

    corner = corners(c);

    file_vcm   = "Vcm_"   + corner + ".csv";
    file_voutp = "Voutp_" + corner + ".csv";
    file_voutn = "Voutn_" + corner + ".csv";
    file_vdiff = "Vdiff_" + corner + ".csv";

    [S.(corner).t_vcm,   S.(corner).vcm]   = readCadenceCSV(file_vcm);
    [S.(corner).t_voutp, S.(corner).voutp] = readCadenceCSV(file_voutp);
    [S.(corner).t_voutn, S.(corner).voutn] = readCadenceCSV(file_voutn);
    [S.(corner).t_vdiff, S.(corner).vdiff] = readCadenceCSV(file_vdiff);

end

%% ===================== APPLY TIME IGNORE =====================
for c = 1:length(corners)

    corner = corners(c);

    [S.(corner).t_vcm,   S.(corner).vcm]   = trimTime(S.(corner).t_vcm,   S.(corner).vcm,   t_ignore);
    [S.(corner).t_voutp, S.(corner).voutp] = trimTime(S.(corner).t_voutp, S.(corner).voutp, t_ignore);
    [S.(corner).t_voutn, S.(corner).voutn] = trimTime(S.(corner).t_voutn, S.(corner).voutn, t_ignore);
    [S.(corner).t_vdiff, S.(corner).vdiff] = trimTime(S.(corner).t_vdiff, S.(corner).vdiff, t_ignore);

end

%% ===================== ALIGN TO TT TIME AXIS =====================
% Use TT as the reference waveform for subtraction.

t_vcm_ref   = S.tt.t_vcm;
t_voutp_ref = S.tt.t_voutp;
t_voutn_ref = S.tt.t_voutn;
t_vdiff_ref = S.tt.t_vdiff;

vcm_tt   = S.tt.vcm;
voutp_tt = S.tt.voutp;
voutn_tt = S.tt.voutn;
vdiff_tt = S.tt.vdiff;

vcm_ss   = interp1(S.ss.t_vcm,   S.ss.vcm,   t_vcm_ref,   "linear", "extrap");
vcm_ff   = interp1(S.ff.t_vcm,   S.ff.vcm,   t_vcm_ref,   "linear", "extrap");

voutp_ss = interp1(S.ss.t_voutp, S.ss.voutp, t_voutp_ref, "linear", "extrap");
voutp_ff = interp1(S.ff.t_voutp, S.ff.voutp, t_voutp_ref, "linear", "extrap");

voutn_ss = interp1(S.ss.t_voutn, S.ss.voutn, t_voutn_ref, "linear", "extrap");
voutn_ff = interp1(S.ff.t_voutn, S.ff.voutn, t_voutn_ref, "linear", "extrap");

vdiff_ss = interp1(S.ss.t_vdiff, S.ss.vdiff, t_vdiff_ref, "linear", "extrap");
vdiff_ff = interp1(S.ff.t_vdiff, S.ff.vdiff, t_vdiff_ref, "linear", "extrap");

%% ===================== DIFFERENCE WAVEFORMS =====================
vdiff_ff_minus_tt = vdiff_ff - vdiff_tt;
vdiff_ss_minus_tt = vdiff_ss - vdiff_tt;

voutp_ff_minus_tt = voutp_ff - voutp_tt;
voutp_ss_minus_tt = voutp_ss - voutp_tt;

voutn_ff_minus_tt = voutn_ff - voutn_tt;
voutn_ss_minus_tt = voutn_ss - voutn_tt;

%% ===================== REPORT TABLE =====================
Corner = ["SS"; "TT"; "FF"];

Vcm_avg = [
    mean(S.ss.vcm);
    mean(S.tt.vcm);
    mean(S.ff.vcm)
];

Vcm_pp = [
    max(S.ss.vcm) - min(S.ss.vcm);
    max(S.tt.vcm) - min(S.tt.vcm);
    max(S.ff.vcm) - min(S.ff.vcm)
];

Voutp_pp = [
    max(S.ss.voutp) - min(S.ss.voutp);
    max(S.tt.voutp) - min(S.tt.voutp);
    max(S.ff.voutp) - min(S.ff.voutp)
];

Voutn_pp = [
    max(S.ss.voutn) - min(S.ss.voutn);
    max(S.tt.voutn) - min(S.tt.voutn);
    max(S.ff.voutn) - min(S.ff.voutn)
];

Vdiff_pp = [
    max(S.ss.vdiff) - min(S.ss.vdiff);
    max(S.tt.vdiff) - min(S.tt.vdiff);
    max(S.ff.vdiff) - min(S.ff.vdiff)
];

Report = table(Corner, Vcm_avg, Vcm_pp, Voutp_pp, Voutn_pp, Vdiff_pp);

disp(" ");
disp("================ DAC OUTPUT REPORT ================");
disp(Report);

%% ===================== DIFFERENCE SUMMARY TABLE =====================
Signal = [
    "Vdiff FF - TT";
    "Vdiff SS - TT";
    "Voutp FF - TT";
    "Voutp SS - TT";
    "Voutn FF - TT";
    "Voutn SS - TT"
];

MaxAbsError_mV = 1e3 * [
    max(abs(vdiff_ff_minus_tt));
    max(abs(vdiff_ss_minus_tt));
    max(abs(voutp_ff_minus_tt));
    max(abs(voutp_ss_minus_tt));
    max(abs(voutn_ff_minus_tt));
    max(abs(voutn_ss_minus_tt))
];

AvgError_mV = 1e3 * [
    mean(vdiff_ff_minus_tt);
    mean(vdiff_ss_minus_tt);
    mean(voutp_ff_minus_tt);
    mean(voutp_ss_minus_tt);
    mean(voutn_ff_minus_tt);
    mean(voutn_ss_minus_tt)
];

DifferenceReport = table(Signal, MaxAbsError_mV, AvgError_mV);

disp(" ");
disp("================ CORNER DIFFERENCE REPORT ================");
disp(DifferenceReport);

%% ============================================================
%  FIGURE 1: VCM SS / TT / FF
%% ============================================================
figure;

plot(t_vcm_ref*1e9, vcm_ss, "LineWidth", 1.4); hold on;
plot(t_vcm_ref*1e9, vcm_tt, "LineWidth", 1.4);
plot(t_vcm_ref*1e9, vcm_ff, "LineWidth", 1.4);

grid on;
xlabel("Time (ns)");
ylabel("V_{CM} (V)");
title("DAC Common-Mode Voltage Across Corners");
legend("SS", "TT", "FF", "Location", "best");

%% ============================================================
%  FIGURE 2: VDIFF FF-TT and SS-TT
%% ============================================================
figure;

plot(t_vdiff_ref*1e9, vdiff_ff_minus_tt*1e3, "LineWidth", 1.4); hold on;
plot(t_vdiff_ref*1e9, vdiff_ss_minus_tt*1e3, "LineWidth", 1.4);

grid on;
xlabel("Time (ns)");
ylabel("\Delta V_{DIFF} (mV)");
title("Differential Output Difference Relative to TT");
legend("Vdiff FF - TT", "Vdiff SS - TT", "Location", "best");

%% ============================================================
%  FIGURE 3: VOUTP FF-TT and SS-TT
%% ============================================================
figure;

plot(t_voutp_ref*1e9, voutp_ff_minus_tt*1e3, "LineWidth", 1.4); hold on;
plot(t_voutp_ref*1e9, voutp_ss_minus_tt*1e3, "LineWidth", 1.4);

grid on;
xlabel("Time (ns)");
ylabel("\Delta V_{OUTP} (mV)");
title("OUTP Difference Relative to TT");
legend("Voutp FF - TT", "Voutp SS - TT", "Location", "best");

%% ============================================================
%  FIGURE 4: VOUTN FF-TT and SS-TT
%% ============================================================
figure;

plot(t_voutn_ref*1e9, voutn_ff_minus_tt*1e3, "LineWidth", 1.4); hold on;
plot(t_voutn_ref*1e9, voutn_ss_minus_tt*1e3, "LineWidth", 1.4);

grid on;
xlabel("Time (ns)");
ylabel("\Delta V_{OUTN} (mV)");
title("OUTN Difference Relative to TT");
legend("Voutn FF - TT", "Voutn SS - TT", "Location", "best");

%% ============================================================
%  Local Functions
%% ============================================================

function [t, y] = readCadenceCSV(filename)

    if ~isfile(filename)
        error("File not found: %s", filename);
    end

    data = readmatrix(filename);

    % Remove rows with NaN or Inf
    data = data(all(isfinite(data), 2), :);

    if size(data,2) < 2
        error("CSV file must have at least two columns: time and waveform value. File: %s", filename);
    end

    t = data(:,1);
    y = data(:,2);

    % Sort by time
    [t, idx] = sort(t);
    y = y(idx);

end

function [t_trim, y_trim] = trimTime(t, y, t_ignore)

    keep = t >= t_ignore;

    t_trim = t(keep);
    y_trim = y(keep);

end