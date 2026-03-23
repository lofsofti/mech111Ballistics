%% final project mech 111 ballistics - Boyer, Coto, Kidd, Reh, Vue
clc; clear; close all;

disp('========================================');
disp('      Ballistics Calculator v1.0        ');
disp('========================================');

%% 1. READ DATA FROM EXCEL
% Have your group set up an Excel file (e.g., 'input_data.xlsx') with sheets
% for Rifle and Shotgun data.
try
    % Uncomment the lines below once your Excel file is ready
    % excelFileName = 'input_data.xlsx';
    % rifleData = readtable(excelFileName, 'Sheet', 'Rifles');
    % shotgunData = readtable(excelFileName, 'Sheet', 'Shotguns');
    disp('Data loaded successfully from Excel.');
catch
    disp('Warning: Could not load Excel file. Proceeding with placeholders.');
end

%% 2. USER INPUT & ERROR CHECKING
% Prompt the user to select which weapon to analyze
weaponType = 0;
while ~ismember(weaponType, [1, 2, 3])
    disp(' ');
    disp('Select a weapon type to analyze:');
    disp('  1. Rifle (Part 1)');
    disp('  2. Shotgun Slug (Part 2)');
    disp('  3. Bow & Arrow (Part 3)');
    
    weaponType = input('Enter 1, 2, or 3: ');
    
    % Error checking logic
    if isempty(weaponType) || ~ismember(weaponType, [1, 2, 3])
        disp('>> ERROR: Invalid selection. Please enter 1, 2, or 3.');
        weaponType = 0; % Reset to keep the loop going
    end
end

%% 3. WEAPON SPECIFIC CALCULATIONS (Group Plug-in Area)
% Initialize empty arrays to hold the final calculated data
ranges = [];
velocities = [];
kineticEnergies = [];
drops = [];

switch weaponType
    case 1
        disp('--- Running Part 1: Rifle Ballistics ---');
        % STUDENT 1: Plug your rifle code here!
        % You need to calculate ranges from 0 to 500 yards.
        % ranges = 0:10:500;
        % velocities = ...
        % kineticEnergies = ...
        % drops = ...
        
    case 2
        disp('--- Running Part 2: Shotgun Slug Ballistics ---');
        % STUDENT 2: Plug your shotgun code here!
        % You need to calculate ranges from 0 to 200 yards.
        % ranges = 0:10:200;
        % velocities = ...
        % kineticEnergies = ...
        % drops = ...
        
    case 3
        disp('--- Running Part 3: Bow & Arrow Ballistics ---');
        % STUDENT 3: Plug your bow & arrow code here!
        % You need to gather specific user inputs for the bow first.
        
        % Example of user input with error checking for arrow weight:
        arrowWeight = -1;
        while arrowWeight <= 0
            arrowWeight = input('Enter arrow weight (grains): ');
            if arrowWeight <= 0
                disp('>> ERROR: Arrow weight must be a positive number.');
            end
        end
        
        % initialVelocity = input('Enter initial arrow velocity (fps): ');
        % targetSpeed = input('Enter target speed (fps): ');
        
        % ranges = 0:1:50;
        % velocities = ...
        % kineticEnergies = ...
        % drops = ...
end

%% 4. PLOTTING THE DATA
% This section will automatically plot whatever data the switch statement outputs
disp('Generating plots...');

% Uncomment this section once your data arrays (ranges, velocities, etc.) are populated
%{
figure('Name', 'Ballistics Analysis', 'NumberTitle', 'off');

% Plot 1: Velocity vs Range
subplot(3, 1, 1);
plot(ranges, velocities, 'LineWidth', 2);
title('Velocity vs. Range');
xlabel('Range (yards)');
ylabel('Velocity (fps)');
grid on;

% Plot 2: Kinetic Energy vs Range
subplot(3, 1, 2);
plot(ranges, kineticEnergies, 'LineWidth', 2);
title('Kinetic Energy vs. Range');
xlabel('Range (yards)');
ylabel('Kinetic Energy (ft-lbs)');
grid on;

% Plot 3: Bullet/Arrow Drop vs Range
subplot(3, 1, 3);
plot(ranges, drops, 'LineWidth', 2);
title('Projectile Drop vs. Range');
xlabel('Range (yards)');
ylabel('Drop (inches)');
grid on;
%}

%% 5. WRITE CALCULATED DATA BACK TO EXCEL
disp('Saving calculated data...');
% Uncomment this section once your variables are populated
%{
% Create a MATLAB table from the calculated arrays
resultsTable = table(ranges', velocities', kineticEnergies', drops', ...
    'VariableNames', {'Range_Yds', 'Velocity_fps', 'KineticEnergy_ftlbs', 'Drop_in'});

% Write the table back to a new Excel file
outputFileName = 'calculated_ballistics_results.xlsx';
writetable(resultsTable, outputFileName, 'Sheet', 'Results');
disp(['Data successfully written to ', outputFileName]);
%}

%% 6. CONCLUSIONS
disp(' ');
disp('========================================');
disp('              CONCLUSIONS               ');
disp('========================================');
% Depending on the weapon type chosen, print out the final conclusions here.
if weaponType == 1
    disp('Rifle Conclusion: (Insert Group conclusions based on the plots here)');
elseif weaponType == 2
    disp('Shotgun Conclusion: (Insert Group conclusions based on the plots here)');
elseif weaponType == 3
    disp('Bow & Arrow Conclusion: (Insert Group conclusions based on the plots here)');
end