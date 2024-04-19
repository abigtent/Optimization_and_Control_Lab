clear;
clc;

% Define inputs
t_padding_start = 0; % Start time for padding
t_padding_end = 35; % End time for padding
t_interesting_start = 5; % Start time for interesting plots
t_interesting_end = 30; % End time for interesting plots

t_total = 0:0.25:t_padding_end; % Total time vector from start to end

% Load MAT files and access the variables
data1 = load("u_optimal_0.12.mat");
data2 = load("u_optimal_1.2.mat");
data3 = load("u_optimal_12.mat");

input1 = data1.u; % Assuming 'u' is the variable name in the MAT file
input2 = data2.u; % Assuming 'u' is the variable name in the MAT file
input3 = data3.u; % Assuming 'u' is the variable name in the MAT file

% Plot inputs
figure;
hold on;
plot(t_total, input1, 'b--', 'LineWidth', 2); % Plot input 1 with blue dashed line
plot(t_total, input2, 'r-.', 'LineWidth', 2); % Plot input 2 with red dash-dot line
plot(t_total, input3, 'Color', [0, 0.7, 0], 'LineStyle', ':', 'LineWidth', 2); % Plot input 3 with darker green dotted line

% Add vertical lines for transitions
plot([t_interesting_start, t_interesting_start], [-pi/4, pi/4], 'k--'); % Vertical line at the start of interesting plots
plot([t_interesting_end, t_interesting_end], [-pi/4, pi/4], 'k--'); % Vertical line at the end of interesting plots

% Shade padded areas with lighter grey and lower opacity
area([t_padding_start, t_interesting_start], [-pi/4, -pi/4], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Initial padding
area([t_interesting_end, t_padding_end], [-pi/4, -pi/4], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Additional padding
area([t_padding_start, t_interesting_start], [pi/4, pi/4], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Initial padding
area([t_interesting_end, t_padding_end], [pi/4, pi/4], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Additional padding

% Change y-axis ticks and labels to display radians
yticks((-pi/8)*2:(pi/8):(pi/8)*2);
yticklabels({'$-\frac{\pi}{4}$', '$-\frac{\pi}{8}$', '$0$', '$\frac{\pi}{8}$', '$\frac{\pi}{4}$'});

% Ensure LaTeX interpreter is enabled for y-axis labels
set(gca, 'TickLabelInterpreter', 'latex');


% Label axes
xlabel('Time [s]', 'FontSize', 15);
ylabel('Input [rad]', 'FontSize', 15);

% Add legend
legend('u_k -> q = 0.12', 'u_k -> q = 1.2', 'u_k -> q = 12', 'Location', 'best', 'FontSize', 15);

% Set axis limits
xlim([0, t_padding_end]);
ylim([-pi/4, pi/4]);

% Add title
title('Input with different weights', 'FontSize', 20);

% Set font size for ticks
set(gca, 'FontSize', 15);

