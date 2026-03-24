%% final project mech 111 ballistics - Boyer, Coto, Kidd, Reh, Vue
% =========================================================================
% Final Project: Ballistics Calculator
% Description: Calculates and plots ballistics data for rifles, shotguns, 
% and bows/arrows. Reads/writes to Excel, checks user input, and plots.
% =========================================================================

clc; clear; close all;

%% 0. SETUP DUMMY EXCEL DATA
% This section creates the Excel file automatically so the program runs
% without you needing to manually create the spreadsheet first.
setupExcelData();

disp('========================================');
disp('      Ballistics Calculator v2.0        ');
disp('========================================');

%% 1. READ DATA FROM EXCEL
filename = 'ballistics_input_data.xlsx';
try
    rifleData = readtable(filename, 'Sheet', 'Rifles');
    shotgunData = readtable(filename, 'Sheet', 'Shotguns');
    disp('Successfully read input data from Excel.');
catch
    error('Could not load Excel file. Please ensure it exists.');
end

%% 2. USER INPUT & ERROR CHECKING
weaponType = 0;
while ~ismember(weaponType, [1, 2, 3])
    disp(' ');
    disp('Select a weapon type to analyze:');
    disp('  1. Rifle (10 Calibers, 0-500 yds)');
    disp('  2. Shotgun Slug (6 Slugs, 0-200 yds)');
    disp('  3. Bow & Arrow (Custom Input, 0-50 yds)');
    
    weaponType = input('Enter 1, 2, or 3: ');
    
    % Error checking logic
    if isempty(weaponType) || ~ismember(weaponType, [1, 2, 3])
        disp('>> ERROR: Invalid selection. Please enter 1, 2, or 3.');
        weaponType = 0; 
    end
end

%% 3. BALLISTICS CALCULATIONS
% Physical constants
g = 32.174; % Gravity in ft/s^2

if weaponType == 1
    disp('--- Calculating Part 1: Rifle Ballistics ---');
    ranges_yd = 0:10:500;
    ranges_ft = ranges_yd * 3;
    numWeapons = height(rifleData);
    names = rifleData.Caliber;
    weights = rifleData.Weight_grains;
    velocities_initial = rifleData.MuzzleVel_fps;
    bcs = rifleData.BC; % Ballistic Coefficient
    
elseif weaponType == 2
    disp('--- Calculating Part 2: Shotgun Slug Ballistics ---');
    ranges_yd = 0:5:200;
    ranges_ft = ranges_yd * 3;
    numWeapons = height(shotgunData);
    names = shotgunData.SlugType;
    weights = shotgunData.Weight_grains;
    velocities_initial = shotgunData.MuzzleVel_fps;
    bcs = shotgunData.BC;
    
elseif weaponType == 3
    disp('--- Calculating Part 3: Bow & Arrow Ballistics ---');
    ranges_yd = 0:1:50;
    ranges_ft = ranges_yd * 3;
    numWeapons = 1;
    names = {'Custom Arrow'};
    
    % Input Arrow Weight with error checking
    arrowWeight = -1;
    while arrowWeight <= 0
        arrowWeight = input('Enter arrow weight (grains): ');
        if arrowWeight <= 0
            disp('>> ERROR: Arrow weight must be a positive number.');
        end
    end
    weights = arrowWeight;
    
    % Input Arrow Velocity with error checking
    initialVelocity = -1;
    while initialVelocity <= 0
        initialVelocity = input('Enter initial arrow velocity (fps): ');
        if initialVelocity <= 0
            disp('>> ERROR: Velocity must be a positive number.');
        end
    end
    velocities_initial = initialVelocity;
    
    % Target speed (optional extra calculation)
    targetSpeed = input('Enter speed of target (fps, 0 if stationary): ');
    
    % Approximate BC for an arrow
    bcs = 0.05; 
end

% Preallocate arrays for calculations
V_matrix = zeros(numWeapons, length(ranges_yd));
KE_matrix = zeros(numWeapons, length(ranges_yd));
Drop_matrix = zeros(numWeapons, length(ranges_yd));

for i = 1:numWeapons
    W = weights(i);
    V0 = velocities_initial(i);
    BC = bcs(i);
    
    for j = 1:length(ranges_yd)
        x_ft = ranges_ft(j);
        
        % 1. Calculate Velocity at range 
        % Simplified drag model: V = V0 * exp(-x / (Constant * BC))
        % The constant 7000 is an arbitrary scaling factor for simplified physics
        V = V0 * exp(-x_ft / (7000 * BC));
        V_matrix(i, j) = V;
        
        % 2. Calculate Kinetic Energy (ft-lbs)
        % KE = (mass_in_grains * V^2) / 450240
        KE_matrix(i, j) = (W * V^2) / 450240;
        
        % 3. Calculate Bullet/Arrow Drop (inches)
        % Time of flight approximation: t = distance / average_velocity
        V_avg = (V0 + V) / 2; 
        if V_avg == 0
            t = 0;
        else
            t = x_ft / V_avg;
        end
        % Drop = 0.5 * g * t^2 (in feet) -> multiply by 12 for inches
        Drop_matrix(i, j) = 0.5 * g * (t^2) * 12;
    end
end

%% 4. PLOTTING THE DATA
disp('Generating plots...');
figure('Name', 'Ballistics Analysis', 'NumberTitle', 'off', 'Position', [100, 100, 800, 800]);

% Plot 1: Velocity
subplot(3, 1, 1);
hold on;
for i = 1:numWeapons
    plot(ranges_yd, V_matrix(i, :), 'LineWidth', 1.5);
end
title('Velocity vs. Range');
xlabel('Range (yards)');
ylabel('Velocity (fps)');
legend(names, 'Location', 'best', 'FontSize', 8);
grid on; hold off;

% Plot 2: Kinetic Energy
subplot(3, 1, 2);
hold on;
for i = 1:numWeapons
    plot(ranges_yd, KE_matrix(i, :), 'LineWidth', 1.5);
end
title('Kinetic Energy vs. Range');
xlabel('Range (yards)');
ylabel('Kinetic Energy (ft-lbs)');
grid on; hold off;

% Plot 3: Drop
subplot(3, 1, 3);
hold on;
for i = 1:numWeapons
    plot(ranges_yd, -Drop_matrix(i, :), 'LineWidth', 1.5); % Negative for drop
end
title('Projectile Drop vs. Range');
xlabel('Range (yards)');
ylabel('Drop (inches)');
grid on; hold off;

%% 5. WRITE CALCULATED DATA TO EXCEL
disp('Saving calculated data to Excel...');
outputFileName = 'calculated_ballistics_results.xlsx';

% Transform matrices into tables for writing
for i = 1:numWeapons
    safeName = matlab.lang.makeValidName(names{i}); % Ensure valid sheet name
    
    resultsTable = table(ranges_yd', V_matrix(i,:)', KE_matrix(i,:)', Drop_matrix(i,:)', ...
        'VariableNames', {'Range_Yds', 'Velocity_fps', 'KineticEnergy_ftlbs', 'Drop_in'});
    
    writetable(resultsTable, outputFileName, 'Sheet', safeName);
end
disp(['Data successfully written to ', outputFileName]);

%% 6. CONCLUSIONS
disp(' ');
disp('========================================');
disp('              CONCLUSIONS               ');
disp('========================================');
if weaponType == 1
    disp('Rifle Conclusion:');
    disp('- Heavier calibers with higher ballistic coefficients (like 6.5 Creedmoor and .338 Lapua)');
    disp('  retain their kinetic energy and velocity much better at 500 yards.');
    disp('- Lighter/slower rounds (like .22 LR) show massive relative bullet drop, making them');
    disp('  unsuitable for long-range engagements.');
elseif weaponType == 2
    disp('Shotgun Conclusion:');
    disp('- Shotgun slugs have immense initial kinetic energy due to their massive weight.');
    disp('- Because of their poor aerodynamic shape (low BC), they lose velocity and energy rapidly.');
    disp('- By 200 yards, the drop is severe, indicating shotguns are strictly short-to-medium range weapons.');
elseif weaponType == 3
    disp('Bow & Arrow Conclusion:');
    disp('- Arrows rely on mass rather than speed for kinetic energy compared to firearms.');
    disp('- Projectile drop is extreme even at 50 yards due to the low initial velocity.');
    if targetSpeed > 0
        disp(['- With a target moving at ', num2str(targetSpeed), ' fps, significant "lead" must be calculated']);
        disp('  because the arrow''s time of flight is long enough for the target to move several feet.');
    end
end


%% =========================================================================
% HELPER FUNCTION: Generates Excel Input Data Automatically
% =========================================================================
function setupExcelData()
    filename = 'ballistics_input_data.xlsx';
    
    % If file exists, we don't need to recreate it
    if isfile(filename)
        return; 
    end
    
    % 10 Commercial Rifle Calibers
    Caliber = {'.22 LR'; '.223 Rem'; '.243 Win'; '.270 Win'; '.308 Win'; ...
               '.30-06 Sprg'; '.300 Win Mag'; '6.5 Creedmoor'; '.338 Lapua'; '.45-70 Govt'};
    Weight_grains = [40; 55; 95; 130; 150; 165; 180; 140; 250; 300];
    MuzzleVel_fps = [1200; 3240; 3100; 3060; 2820; 2800; 2960; 2710; 2900; 2000];
    BC = [0.120; 0.243; 0.355; 0.433; 0.415; 0.477; 0.505; 0.582; 0.625; 0.250];
    rifleTable = table(Caliber, Weight_grains, MuzzleVel_fps, BC);
    
    % 6 Commercial Shotgun Slugs
    SlugType = {'12ga 1oz Foster'; '12ga Sabot'; '20ga Foster'; '20ga Sabot'; '410ga Slug'; '10ga Slug'};
    Weight_grains_sg = [437.5; 300; 328; 260; 110; 766];
    MuzzleVel_fps_sg = [1560; 2000; 1600; 1900; 1830; 1280];
    BC_sg = [0.11; 0.20; 0.09; 0.18; 0.07; 0.10];
    shotgunTable = table(SlugType, Weight_grains_sg, MuzzleVel_fps_sg, BC_sg, ...
        'VariableNames', {'SlugType', 'Weight_grains', 'MuzzleVel_fps', 'BC'});
    
    % Write to Excel
    writetable(rifleTable, filename, 'Sheet', 'Rifles');
    writetable(shotgunTable, filename, 'Sheet', 'Shotguns');
end