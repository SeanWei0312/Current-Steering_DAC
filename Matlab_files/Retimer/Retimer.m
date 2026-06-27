clear; clc; close all;

%% ================= SETTINGS =================
files  = ["D.csv", "Dret.csv", "CLKT.csv", "CLKC.csv"];
names  = ["D<0>", "Dret<0>", "CLKT", "CLKC"];

t_min_ns = 400;
t_max_ns = 440;

VDD = 1.8;
v10 = 0.1 * VDD;
v50 = 0.5 * VDD;
v90 = 0.9 * VDD;

%% ================= LOAD ALL DATA =================
wave = struct();

for k = 1:length(files)

    data = readmatrix(files(k));

    t = data(:,1);
    v = data(:,2);

    valid = isfinite(t) & isfinite(v);
    t = t(valid);
    v = v(valid);

    % Convert time to ns if CSV time is in seconds
    if max(t) < 1e-3
        t_ns = t * 1e9;
    else
        t_ns = t;
    end

    % Keep 400 ns to 440 ns
    keep = (t_ns >= t_min_ns) & (t_ns <= t_max_ns);
    t_ns = t_ns(keep);
    v = v(keep);

    wave(k).t = t_ns;
    wave(k).v = v;
end

%% ================= PLOT =================
figure;

for k = 1:length(files)

    subplot(4,1,k);
    plot(wave(k).t, wave(k).v, 'LineWidth', 1.5);
    grid on;

    ylabel('V (V)');
    title(names(k));

    xlim([t_min_ns t_max_ns]);
    ylim([-0.1 1.9]);

    if k == length(files)
        xlabel('Time (ns)');
    end
end

sgtitle('Input Data, Retimed Data, and Clocks from 400 ns to 440 ns');

%% ================= CALCULATE CLKT -> Dret DELAY =================
t_Dret = wave(2).t;
v_Dret = wave(2).v;

t_CLKT = wave(3).t;
v_CLKT = wave(3).v;

% CLKT rising 50% crossing times
clkt_rise_50 = crossing_time(t_CLKT, v_CLKT, v50, "rise");

% Dret 50% crossing times
dret_rise_50 = crossing_time(t_Dret, v_Dret, v50, "rise");
dret_fall_50 = crossing_time(t_Dret, v_Dret, v50, "fall");

rising_delay_ns  = [];
falling_delay_ns = [];

% Rising delay: latest CLKT rising edge before each Dret rising edge
for i = 1:length(dret_rise_50)

    t_out = dret_rise_50(i);
    idx = find(clkt_rise_50 < t_out, 1, 'last');

    if ~isempty(idx)
        rising_delay_ns(end+1,1) = t_out - clkt_rise_50(idx);
    end
end

% Falling delay: latest CLKT rising edge before each Dret falling edge
for i = 1:length(dret_fall_50)

    t_out = dret_fall_50(i);
    idx = find(clkt_rise_50 < t_out, 1, 'last');

    if ~isempty(idx)
        falling_delay_ns(end+1,1) = t_out - clkt_rise_50(idx);
    end
end

all_delay_ns = [rising_delay_ns; falling_delay_ns];

avg_rising_delay_ns  = mean(rising_delay_ns,  'omitnan');
avg_falling_delay_ns = mean(falling_delay_ns, 'omitnan');
avg_delay_ns         = mean(all_delay_ns,     'omitnan');

%% ================= CALCULATE Dret 0.1-0.9 SLEW RATE =================
dret_rise_10 = crossing_time(t_Dret, v_Dret, v10, "rise");
dret_rise_90 = crossing_time(t_Dret, v_Dret, v90, "rise");

dret_fall_90 = crossing_time(t_Dret, v_Dret, v90, "fall");
dret_fall_10 = crossing_time(t_Dret, v_Dret, v10, "fall");

rise_slew_V_per_ns = [];
fall_slew_V_per_ns = [];

Nrise = min(length(dret_rise_10), length(dret_rise_90));
for i = 1:Nrise
    dt = dret_rise_90(i) - dret_rise_10(i);
    if dt > 0
        rise_slew_V_per_ns(end+1,1) = (v90 - v10) / dt;
    end
end

Nfall = min(length(dret_fall_90), length(dret_fall_10));
for i = 1:Nfall
    dt = dret_fall_10(i) - dret_fall_90(i);
    if dt > 0
        fall_slew_V_per_ns(end+1,1) = (v90 - v10) / dt;
    end
end

all_slew_V_per_ns = [rise_slew_V_per_ns; fall_slew_V_per_ns];

avg_rise_slew = mean(rise_slew_V_per_ns, 'omitnan');
avg_fall_slew = mean(fall_slew_V_per_ns, 'omitnan');
avg_all_slew  = mean(all_slew_V_per_ns,  'omitnan');

%% ================= PRINT LOG ONLY =================
fprintf('\n========== Dret Timing Results ==========\n');
fprintf('Time window                       : %.1f ns to %.1f ns\n', t_min_ns, t_max_ns);
fprintf('VDD                               : %.3f V\n', VDD);
fprintf('CLKT -> Dret avg rising delay     : %.4f ns\n', avg_rising_delay_ns);
fprintf('CLKT -> Dret avg falling delay    : %.4f ns\n', avg_falling_delay_ns);
fprintf('CLKT -> Dret avg delay            : %.4f ns\n', avg_delay_ns);
fprintf('Dret avg rising slew 0.1-0.9      : %.4f V/ns\n', avg_rise_slew);
fprintf('Dret avg falling slew 0.9-0.1     : %.4f V/ns\n', avg_fall_slew);
fprintf('Dret avg total slew               : %.4f V/ns\n', avg_all_slew);
fprintf('=========================================\n');

%% ================= LOCAL FUNCTION =================
function tcross = crossing_time(t, v, level, edgeType)

    tcross = [];

    for i = 1:length(v)-1

        v1 = v(i);
        v2 = v(i+1);
        t1 = t(i);
        t2 = t(i+1);

        if edgeType == "rise"
            isCross = (v1 < level) && (v2 >= level);
        elseif edgeType == "fall"
            isCross = (v1 > level) && (v2 <= level);
        else
            error("edgeType must be rise or fall");
        end

        if isCross
            % Linear interpolation
            tc = t1 + (level - v1) * (t2 - t1) / (v2 - v1);
            tcross(end+1,1) = tc;
        end
    end
end