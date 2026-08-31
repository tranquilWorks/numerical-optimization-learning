%% P02 - Expose Floating-Point Roundoff
% Guiding question:
% What inputs, observable effects, and failure modes matter when you expose Floating-Point Roundoff?
%
% Work through one Live Editor section at a time. Run experiment.m sections
% in order rather than running ahead to every figure.

%% Read - floating-point values lie on a scale-dependent grid
disp('A floating-point accumulator moves on a grid, not on a continuous number line.');
disp('Near x, eps(single(x)) is one local unit in the last place (ULP).');
disp('Each addition stores fl(x + h), so a nonzero h can be rounded or absorbed.');
disp('P01 assumed an update changes the iterate; P02 exposes when representation breaks that assumption.');

%% Predict once before the baseline
disp('Prediction: will adding 0.75 ULP 64 times undershoot, match, or overshoot the analytical change?');

%% Baseline - run only the first section of experiment.m
disp('Open experiment.m and run the deterministic baseline section.');
disp('Compare stored change with the reference, then inspect signed error in starting ULPs.');

%% One lever and changed view - update size
disp('Run Sweep 1 only. Change update size while x_0=1 and the addition count stay fixed.');
disp('First describe the changed error and changed-step fraction; then explain the rounding direction.');

%% Reset, second lever, and changed view - accumulator magnitude
disp('Return to the baseline, then run Sweep 2 only. The absolute update now stays fixed.');
disp('As x_0 grows, local spacing grows until the same update is absorbed.');

%% Mechanism-first explanation
disp('The relevant ratio is stored update divided by local spacing, not update size alone.');
disp('Repeated rounding accumulates signed error; sub-half-ULP updates can produce stagnation.');

%% Broken assumption
disp('Run the deliberately broken case in experiment.m.');
disp('It breaks grouping invariance: 1024 individually rounded updates do not equal one grouped update.');

%% Execute the fixed observations before opening controls
% launch_lesson runs the sectioned experiment in its documented order while
% this module folder is on the MATLAB path. In the Live Editor, run the same
% experiment sections individually when tutoring one transition at a time.
experiment;

%% Open the bounded live controls after the fixed observations
% Reset to the baseline after changing each control so causes stay isolated.
interactive;

%% Check and teach back
disp('Run run_checks, answer checks.md, then teach back the mechanism before the symptom.');
