clear;
clc;

% Load MAT files and access the variables
data1 = load("LQ_test.mat");
data2 = load("pitch_optimal.mat");

input1 = data1.ans;
input2 = data2.x3;

% Extract pitch
input1 = input1(4, :);

% Transfer from degrees to radians
input1 = deg2rad(input1);
%input2 = deg2rad(input2);

% Define inputs
t_padding_start = 0; % Start time for padding
t_padding_end = 35; % End time for padding
min_size = length(input1);
t_total = linspace(t_padding_start, t_padding_end, min_size); % Total time vector from start to end

% Interpolate input2 to match the length of input1
input2_interp = interp1(linspace(0, t_padding_end, length(input2)), input2, t_total);

% Plot inputs
figure;
hold on;
plot(t_total, input1, 'b--', 'LineWidth', 2); % Plot input 1 with blue dashed line
plot(t_total, input2_interp, 'r-.', 'LineWidth', 2); % Plot interpolated input 2 with red dash-dot line

% Add vertical lines for transitions
plot([5, 5], [-pi, 4.2*pi], 'k--'); % Vertical line at the end of initial padding
plot([30, 30], [-pi, 4.2*pi], 'k--'); % Vertical line at the end of interesting plots

% Shade padded areas with lighter grey and lower opacity
area([0, 5], [-pi, -pi], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Initial padding
area([30, 35], [-pi, -pi], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Additional padding
area([0, 5], [4.2*pi, 4.2*pi], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Initial padding
area([30, 35], [4.2*pi, 4.2*pi], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Additional padding

% Label axes
xlabel('Time [s]','FontSize', 15);
ylabel('Pitch [rad]', 'FontSize', 15);

% Change y-axis ticks and labels to display radians
yticks((-pi:pi/8:4*pi));
yticklabels({'$-\pi$', '$-\frac{7\pi}{8}$', '$-\frac{3\pi}{4}$', '$-\frac{5\pi}{8}$', '$-\frac{\pi}{2}$', '$-\frac{3\pi}{8}$', '$-\frac{\pi}{4}$', '$-\frac{\pi}{8}$', '$0$', '$\frac{\pi}{8}$', '$\frac{\pi}{4}$', '$\frac{3\pi}{8}$', '$\frac{\pi}{2}$', '$\frac{5\pi}{8}$', '$\frac{3\pi}{4}$', '$\frac{7\pi}{8}$', '$\pi$', '$\frac{9\pi}{8}$', '$\frac{5\pi}{4}$', '$\frac{11\pi}{8}$', '$\frac{3\pi}{2}$', '$\frac{13\pi}{8}$', '$\frac{7\pi}{4}$', '$\frac{15\pi}{8}$', '$2\pi$','FontSize', 20});
% Ensure LaTeX interpreter is enabled for y-axis labels
set(gca, 'TickLabelInterpreter', 'latex');

% Add legend
legend('p_k', 'p_k *', 'Location', 'best','FontSize',15);

% Set axis limits
xlim([0, t_padding_end]);
ylim([-pi/4, pi/4]);

% Add title
title('Test: Comparison of p* and p with LQ control (q = 0.12)', 'FontSize', 15);

% Set font size for ticks
set(gca, 'FontSize', 15);