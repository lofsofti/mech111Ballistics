% Part 3 - Bow & Arrow Ballistics (Metric/Imperial Hybrid)
clear; clc; close all;

% 1. Input information from the user
fprintf('--- Bow & Arrow Ballistics Simulator ---\n');
arrow_weight_g = input('Enter Arrow Weight (in grams, e.g., 26): ');
v_initial_fps = input('Enter Initial Arrow Velocity (in feet per second, e.g., 300): ');
target_speed_mph = input('Enter Speed of Target (in miles per hour, e.g., 5): ');

% Convert target speed from mph to feet per second (fps)
% 1 mph = 1.46667 fps
target_speed_fps = target_speed_mph * 1.46667;

% 2. Calculate the velocities of this arrow from 0 to 50 yards
% Define the ranges in yards
ranges_yards = 0:1:50;
ranges_feet = ranges_yards * 3;

% Assume a standard archery velocity loss (drag factor)
% A typical arrow loses about 1% of its speed per 10 yards.
drag_coefficient = 0.001; 
v_fps = v_initial_fps * exp(-drag_coefficient * ranges_yards);

% Calculate time of flight to each range
% Time = Distance / Average Velocity
time_of_flight = zeros(1, length(ranges_yards));
for i = 2:length(ranges_yards)
    avg_velocity = (v_initial_fps + v_fps(i)) / 2;
    time_of_flight(i) = ranges_feet(i) / avg_velocity;
end

% 3. Calculate the Kinetic Energy of the arrow at the same ranges in Joules
% To find Joules, we need mass in kg and velocity in meters per second (m/s)
mass_kg = arrow_weight_g / 1000;
v_ms = v_fps * 0.3048; % 1 fps = 0.3048 m/s

% Formula for KE in Joules: KE = 0.5 * m * v^2
KE_Joules = 0.5 * mass_kg * (v_ms.^2);

% 4. Calculate the drop of the arrow at these ranges
% Formula for drop in inches: Drop = 0.5 * g * t^2
% Gravity (g) = 32.174 ft/s^2, which is 386.088 inches/s^2
g_in_per_s2 = 386.088;
arrow_drop_inches = 0.5 * g_in_per_s2 * (time_of_flight.^2);

% Calculate the required lead for a moving target
% Lead = Target Speed * Time of Flight
target_lead_feet = target_speed_fps .* time_of_flight;

% --- Visualization ---
figure('Name', 'Bow & Arrow Ballistics', 'Position', [100, 100, 1000, 600]);

% Plot Velocity
subplot(2, 2, 1);
plot(ranges_yards, v_fps, 'b-', 'LineWidth', 2);
title('Arrow Velocity over Range');
xlabel('Range (yards)');
ylabel('Velocity (fps)');
grid on;

% Plot Kinetic Energy
subplot(2, 2, 2);
plot(ranges_yards, KE_Joules, 'r-', 'LineWidth', 2);
title('Kinetic Energy over Range');
xlabel('Range (yards)');
ylabel('Kinetic Energy (Joules)');
grid on;

% Plot Arrow Drop
subplot(2, 2, 3);
% Multiplying by -1 to show downward drop
plot(ranges_yards, -arrow_drop_inches, 'k-', 'LineWidth', 2);
title('Arrow Drop over Range');
xlabel('Range (yards)');
ylabel('Drop (inches)');
grid on;

% Plot Target Lead
subplot(2, 2, 4);
plot(ranges_yards, target_lead_feet, 'm-', 'LineWidth', 2);
title('Required Lead for Moving Target');
xlabel('Range (yards)');
ylabel('Lead Distance (feet)');
grid on;

% 5. Draw conclusions from the data you created
fprintf('\n--- Conclusions & Data Summary at 50 Yards ---\n');
velocity_loss = v_initial_fps - v_fps(end);
ke_loss = KE_Joules(1) - KE_Joules(end);
max_drop = arrow_drop_inches(end);
max_lead = target_lead_feet(end);

fprintf('1. Velocity Decay: The arrow lost %.1f fps over 50 yards, impacting the target at %.1f fps.\n', velocity_loss, v_fps(end));
fprintf('2. Kinetic Energy (Penetration): The arrow retains %.1f Joules of energy at 50 yards (a loss of %.1f Joules). ', KE_Joules(end), ke_loss);

% 40 ft-lbs is roughly equal to 54.2 Joules
if KE_Joules(end) >= 54.2
    fprintf('This is sufficient for harvesting most large game like deer.\n');
else
    fprintf('This energy level is considered low for large game and is better suited for small game or target practice.\n');
end

fprintf('3. Arrow Drop: Without adjusting aim, the arrow drops %.1f inches at 50 yards. This demonstrates the parabolic trajectory and why precise yardage estimation is critical.\n', max_drop);

if target_speed_mph > 0
    fprintf('4. Target Lead: To hit a target moving at %.1f mph at 50 yards, you must aim %.1f feet ahead of it. This highlights the difficulty of taking ethical shots at moving game.\n', target_speed_mph, max_lead);
else
    fprintf('4. Target Lead: The target is stationary, so no lead is required.\n');
end