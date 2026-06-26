clear; clc; close all;

data = readmatrix('vdiff_tt.csv');

code = data(:,1);
Vdiff = data(:,2);
OUTp = data(:,3);
OUTn = data(:,4);
Vcm  = (OUTp + OUTn)/2;

valid = ~isnan(code) & ~isnan(Vdiff) & ~isnan(OUTp) & ~isnan(OUTn);
code = code(valid);
Vdiff = Vdiff(valid);
OUTp = OUTp(valid);
OUTn = OUTn(valid);
Vcm = Vcm(valid);

[code, idx] = sort(code);
Vdiff = Vdiff(idx);
OUTp = OUTp(idx);
OUTn = OUTn(idx);
Vcm  = Vcm(idx);

LSB = (Vdiff(end) - Vdiff(1)) / 255;

step = diff(Vdiff);
DNL = step / LSB - 1;

Videal = Vdiff(1) + code * LSB;
INL = (Vdiff - Videal) / LSB;

fprintf('Vdiff_pp = %.6f V\n', Vdiff(end)-Vdiff(1));
fprintf('LSB = %.6f mV\n', LSB*1e3);
fprintf('Max DNL = %.4f LSB\n', max(DNL));
fprintf('Min DNL = %.4f LSB\n', min(DNL));
fprintf('Max INL = %.4f LSB\n', max(INL));
fprintf('Min INL = %.4f LSB\n', min(INL));

fprintf('Vcm avg = %.6f V\n', mean(Vcm));
fprintf('Vcm min = %.6f V\n', min(Vcm));
fprintf('Vcm max = %.6f V\n', max(Vcm));
fprintf('Vcm variation = %.6f mV\n', (max(Vcm)-min(Vcm))*1e3);

fprintf('OUTp swing = %.6f V\n', max(OUTp)-min(OUTp));
fprintf('OUTp min = %.6f V\n', min(OUTp));
fprintf('OUTp max = %.6f V\n', max(OUTp));

fprintf('OUTn swing = %.6f V\n', max(OUTn)-min(OUTn));
fprintf('OUTn min = %.6f V\n', min(OUTn));
fprintf('OUTn max = %.6f V\n', max(OUTn));

figure;
plot(code(1:end-1), DNL, 'LineWidth', 1.5);
grid on;
xlabel('Code');
ylabel('DNL [LSB]');
title('DAC DNL');
yline(1,'--');
yline(-1,'--');

figure;
plot(code, INL, 'LineWidth', 1.5);
grid on;
xlabel('Code');
ylabel('INL [LSB]');
title('DAC INL');
yline(2,'--');
yline(-2,'--');