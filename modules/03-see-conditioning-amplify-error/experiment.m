%% P03 - See Conditioning Amplify Error
% Run one section at a time in the Live Editor. All values are deterministic.

%% Deterministic baseline - a weak difference between two sensor rows
baselineCondition = 100;
baselineErrorFraction = 0.001; % 0.1 percent = 1000 parts per million
baselineErrorAngle = 90;       % aligned with the weak difference direction
baseline = model(baselineCondition,baselineErrorFraction,baselineErrorAngle);

fprintf('P03 deterministic baseline (two calibrated sensor channels)\n');
fprintf('condition number kappa_2 = %.0f (dimensionless)\n',baseline.conditionNumber);
fprintf('angle between sensor rows = %.6f degrees\n',baseline.rowSeparationDegrees);

figure('Name','P03 baseline - sensor geometry');
plot([0 baseline.systemMatrix(1,1)],[0 baseline.systemMatrix(1,2)], ...
    'o-','LineWidth',1.6,'DisplayName','Sensor row 1'); hold on;
plot([0 baseline.systemMatrix(2,1)],[0 baseline.systemMatrix(2,2)], ...
    's-','LineWidth',1.6,'DisplayName','Sensor row 2');
grid on; axis equal;
xlabel('Source 1 sensitivity (sensor units / source unit)');
ylabel('Source 2 sensitivity (sensor units / source unit)');
title(sprintf('Nearly redundant rows: separation %.3f degrees', ...
    baseline.rowSeparationDegrees));
legend('Location','best');

assert(abs(baseline.rowSeparationDegrees-2*atand(1/baselineCondition))<1e-14, ...
    'The baseline row separation must match the transparent geometry.');

%% Baseline changed view - source error after the prediction
fprintf('relative measurement error = %.4f percent\n',baseline.inputErrorPercent);
fprintf('relative source error = %.4f percent\n',baseline.solutionErrorPercent);
fprintf('directional amplification = %.4f (dimensionless)\n', ...
    baseline.directionalAmplification);
fprintf('condition bound = %.4f percent\n',baseline.conditionBoundPercent);
fprintf('relative residual against perturbed data = %.3e (dimensionless)\n', ...
    baseline.relativeResidual);

figure('Name','P03 baseline changed view - inferred source');
plot([0 baseline.trueState(1)],[0 baseline.trueState(2)], ...
    'o-','LineWidth',1.8,'DisplayName','True source'); hold on;
plot([0 baseline.estimatedState(1)],[0 baseline.estimatedState(2)], ...
    's-','LineWidth',1.8,'DisplayName','Inferred source');
grid on; axis equal;
xlabel('Source component 1 (source units)');
ylabel('Source component 2 (source units)');
title('A 0.1% data error becomes a 10% source error');
legend('Location','best');

assert(abs(baseline.inputErrorPercent-0.1)<1e-12, ...
    'The baseline measurement error should be 0.1 percent.');
assert(abs(baseline.solutionErrorPercent-10)<1e-10, ...
    'The weak-direction source error should be 10 percent.');
assert(abs(baseline.directionalAmplification-baselineCondition)<1e-12, ...
    'A weak-direction perturbation should attain the condition bound.');

%% Sweep 1 - conditioning with perturbation size and direction fixed
conditionValues = [1 3 10 30 100 300 1000];
conditionInputPercent = zeros(size(conditionValues));
conditionSolutionPercent = zeros(size(conditionValues));
conditionAmplification = zeros(size(conditionValues));
conditionRowAngle = zeros(size(conditionValues));
for i = 1:numel(conditionValues)
    sweepCondition = model(conditionValues(i),baselineErrorFraction,90);
    conditionInputPercent(i) = sweepCondition.inputErrorPercent;
    conditionSolutionPercent(i) = sweepCondition.solutionErrorPercent;
    conditionAmplification(i) = sweepCondition.directionalAmplification;
    conditionRowAngle(i) = sweepCondition.rowSeparationDegrees;
end

figure('Name','P03 sweep 1 - conditioning');
loglog(conditionValues,conditionInputPercent,'--','LineWidth',1.5, ...
    'DisplayName','Measurement error'); hold on;
loglog(conditionValues,conditionSolutionPercent,'o-','LineWidth',1.5, ...
    'DisplayName','Source error');
grid on; xlabel('Condition number \kappa_2 (dimensionless)');
ylabel('Relative error (%)');
title('Sweep 1: conditioning sets worst-direction gain');
legend('Location','best');

assert(all(diff(conditionSolutionPercent)>0), ...
    'Source error should grow as conditioning worsens in the weak direction.');
assert(max(abs(conditionAmplification-conditionValues))<1e-10, ...
    'The weak-direction sweep should attain each condition-number bound.');

%% Sweep 1 changed view - sensor rows become less distinguishable
figure('Name','P03 sweep 1 changed view - sensor geometry');
semilogx(conditionValues,conditionRowAngle,'s-','LineWidth',1.5);
grid on; xlabel('Condition number \kappa_2 (dimensionless)');
ylabel('Angle between sensor rows (degrees)');
title('Rows become harder to distinguish');

assert(all(diff(conditionRowAngle)<0), ...
    'Sensor-row separation should shrink as conditioning worsens.');

%% Sweep 2 - perturbation direction with conditioning and size fixed
directionAngles = [0 15 30 45 60 75 90];
directionInputPercent = zeros(size(directionAngles));
directionSolutionPercent = zeros(size(directionAngles));
directionAmplification = zeros(size(directionAngles));
for i = 1:numel(directionAngles)
    sweepDirection = model(baselineCondition,baselineErrorFraction,directionAngles(i));
    directionInputPercent(i) = sweepDirection.inputErrorPercent;
    directionSolutionPercent(i) = sweepDirection.solutionErrorPercent;
    directionAmplification(i) = sweepDirection.directionalAmplification;
end

figure('Name','P03 sweep 2 - perturbation direction');
plot(directionAngles,directionSolutionPercent,'o-','LineWidth',1.5); hold on;
plot(directionAngles,directionInputPercent,'--','LineWidth',1.5);
grid on; xlabel('Error angle toward weak direction (degrees)');
ylabel('Relative error (%)');
title('Sweep 2: equal-size errors need not amplify equally');
legend('Source error','Measurement error','Location','best');

assert(max(abs(directionInputPercent-directionInputPercent(1)))<1e-12, ...
    'Sweep 2 must hold perturbation magnitude fixed.');

%% Sweep 2 changed view - realized gain versus the condition bound
figure('Name','P03 sweep 2 changed view - directional gain');
plot(directionAngles,directionAmplification,'s-','LineWidth',1.5); hold on;
plot(directionAngles,baselineCondition*ones(size(directionAngles)),'--', ...
    'LineWidth',1.5);
grid on; xlabel('Error angle toward weak direction (degrees)');
ylabel('Directional amplification (dimensionless)');
title('Condition number is a worst-case bound');
legend('Realized direction','Condition bound','Location','best');

assert(abs(directionAmplification(1)-1)<1e-12, ...
    'A strong-direction perturbation should have unit amplification.');
assert(abs(directionAmplification(end)-baselineCondition)<1e-12, ...
    'A weak-direction perturbation should reach the condition number.');

%% Deliberately broken case - a tiny residual is not an accuracy certificate
% Broken assumption: fitting the perturbed measurements with a tiny residual
% proves that the inferred source is close to the unknown true source.
broken = model(1e6,1e-6,90); % one part per million in the weak direction
brokenMetrics = [broken.inputErrorPercent broken.solutionErrorPercent ...
    100*broken.relativeResidual];
figure('Name','P03 deliberately broken residual certificate');
semilogy(1:3,max(brokenMetrics,eps),'o','LineWidth',1.8,'MarkerSize',8);
grid on; xlim([0.5 3.5]);
set(gca,'XTick',1:3,'XTickLabel',{'Input error','Source error','Fit residual'});
xlabel('Diagnostic quantity'); ylabel('Relative magnitude (%)');
title('Broken: perturbed-data fit hides order-one source error');

fprintf('Broken case: input error = %.6g percent, source error = %.6g percent\n', ...
    broken.inputErrorPercent,broken.solutionErrorPercent);
fprintf('Broken case: relative residual = %.3e, row separation = %.9f degrees\n', ...
    broken.relativeResidual,broken.rowSeparationDegrees);
fprintf(['Violated assumption: a tiny residual against perturbed data certifies ' ...
    'closeness to the unknown true source.\n']);
assert(abs(broken.solutionErrorPercent-100)<1e-7, ...
    'One-ppm weak-direction input error should create 100 percent source error.');
assert(broken.relativeResidual<1e-12, ...
    'The perturbed-data residual should remain tiny in the broken case.');
