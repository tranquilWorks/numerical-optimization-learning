%% P02 - Expose Floating-Point Roundoff
% Run one section at a time in the Live Editor. All values are deterministic.

%% Deterministic baseline - ordered single-precision additions
baselineStart = 1;
baselineIncrement = 3*2^-25; % 0.75 ULP at single(1)
baselineAdditions = 64;
baseline = model(baselineStart,baselineIncrement,baselineAdditions);

fprintf('P02 deterministic baseline (single precision)\n');
fprintf('start = %.9g value units\n',baseline.storedStart);
fprintf('local spacing = %.9g value units\n',baseline.spacingAtStart);
fprintf('stored update = %.9g value units = %.3f starting ULP\n', ...
    baseline.storedIncrement,baseline.incrementInUlps);
fprintf('expected change = %.9g value units\n',baseline.expectedChange);
fprintf('observed change = %.9g value units\n',baseline.observedChange);
fprintf('final signed error = %.3f starting ULP\n',baseline.finalErrorInUlps);
fprintf('changed additions = %d of %d\n',baseline.changedSteps,baselineAdditions);

figure('Name','P02 deterministic baseline');
subplot(1,2,1);
plot(baseline.step,baseline.referenceChange,'--', ...
    'LineWidth',1.5,'DisplayName','Analytical reference'); hold on;
plot(baseline.step,baseline.observedChangeHistory,'o-', ...
    'LineWidth',1.1,'MarkerSize',3,'DisplayName','Stored single result');
grid on; xlabel('Addition count'); ylabel('Accumulated change (value units)');
title('Baseline: stored change versus reference'); legend('Location','best');
subplot(1,2,2);
plot(baseline.step,baseline.errorInStartUlps,'LineWidth',1.5);
grid on; xlabel('Addition count'); ylabel('Signed error (starting-point ULP)');
title('Roundoff accumulates with direction');

assert(baseline.changedSteps==baselineAdditions, ...
    'The baseline should change on every addition.');
assert(baseline.finalErrorInUlps==16, ...
    'The baseline should finish 16 starting ULPs above the reference.');

%% Sweep 1 - update size with start and operation count fixed
updateRatios = [0.25 0.75 1 1.25 1.75];
updateFinalError = zeros(size(updateRatios));
updateChangedPercent = zeros(size(updateRatios));
unitSpacing = double(eps(single(1)));
for i = 1:numel(updateRatios)
    sweepUpdate = model(1,updateRatios(i)*unitSpacing,64);
    updateFinalError(i) = sweepUpdate.finalErrorInUlps;
    updateChangedPercent(i) = 100*sweepUpdate.changedSteps/64;
end

figure('Name','P02 sweep 1 - update size');
subplot(1,2,1);
plot(updateRatios,updateFinalError,'o-','LineWidth',1.4);
grid on; xlabel('Requested update at x_0=1 (local ULP)');
ylabel('Final signed error (starting-point ULP)');
title('Sweep 1: update size sets rounding direction');
subplot(1,2,2);
plot(updateRatios,updateChangedPercent,'s-','LineWidth',1.4);
grid on; xlabel('Requested update at x_0=1 (local ULP)');
ylabel('Additions that changed storage (%)'); ylim([-5 105]);
title('Sub-half-ULP updates are absorbed');

%% Sweep 2 - accumulator magnitude with update and operation count fixed
startValues = [0.25 1 4 16];
fixedIncrement = 3*2^-25;
scaleSpacing = zeros(size(startValues));
scaleUpdateRatio = zeros(size(startValues));
scaleChangedPercent = zeros(size(startValues));
for i = 1:numel(startValues)
    sweepScale = model(startValues(i),fixedIncrement,64);
    scaleSpacing(i) = sweepScale.spacingAtStart;
    scaleUpdateRatio(i) = sweepScale.incrementInUlps;
    scaleChangedPercent(i) = 100*sweepScale.changedSteps/64;
end

figure('Name','P02 sweep 2 - accumulator magnitude');
subplot(1,2,1);
loglog(startValues,scaleSpacing,'o-','LineWidth',1.4);
grid on; xlabel('Starting accumulator x_0 (value units)');
ylabel('Local spacing (value units)');
title('Sweep 2: spacing grows with magnitude');
subplot(1,2,2);
semilogx(startValues,scaleUpdateRatio,'o-','LineWidth',1.4, ...
    'DisplayName','Update / local ULP'); hold on;
semilogx(startValues,scaleChangedPercent/100,'s-','LineWidth',1.4, ...
    'DisplayName','Changed-step fraction');
grid on; xlabel('Starting accumulator x_0 (value units)');
ylabel('Dimensionless ratio'); ylim([-0.05 3.2]);
title('The same update becomes invisible'); legend('Location','best');

%% Deliberately broken case - individually lost updates versus one grouped update
% Broken assumption: floating-point addition is grouping invariant, so many
% individually nonzero updates must eventually change the accumulator.
broken = model(1,2^-25,1024); % 0.25 starting ULP per update
figure('Name','P02 deliberately broken case');
plot(broken.step,broken.referenceChange,'--', ...
    'LineWidth',1.5,'DisplayName','Analytical grouped change'); hold on;
plot(broken.step,broken.observedChangeHistory,'LineWidth',1.5, ...
    'DisplayName','Ordered stored change');
grid on; xlabel('Addition count'); ylabel('Accumulated change (value units)');
title('Broken: every nonzero update is absorbed'); legend('Location','best');

fprintf('Broken case: stepwise final = %.9g, round-once final = %.9g\n', ...
    broken.stepwiseFinal,broken.roundedOnceFinal);
fprintf('Violated assumption: floating-point addition is grouping invariant.\n');
assert(broken.changedSteps==0,'Every broken-case update should be absorbed.');
assert(broken.roundedOnceFinal>broken.stepwiseFinal, ...
    'Grouping the updates once should expose the lost total.');
