clear; clc; close all;

data = readmatrix('vdiff_ff.csv');

code = data(:,1);
Vdiff = data(:,2);

valid = ~isnan(code) & ~isnan(Vdiff);
code = code(valid);
Vdiff = Vdiff(valid);

[code, idx] = sort(code);
Vdiff = Vdiff(idx);

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