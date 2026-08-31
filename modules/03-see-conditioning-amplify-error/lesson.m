%% P03 - See Conditioning Amplify Error
% Guiding question:
% What inputs, observable effects, and failure modes matter when you see Conditioning Amplify Error?
%
% Work through one Live Editor section at a time. Run experiment.m sections
% in order rather than running ahead to every figure.

%% Read - nearly redundant sensors hide one source direction
disp('Two calibrated sensors measure the source average strongly and the difference weakly.');
disp('Nearly parallel sensor rows make some error directions much more consequential than others.');
disp('P02 supplied a small representation error; P03 shows how problem geometry can amplify it.');

%% Predict once before the baseline
disp('Prediction: at kappa=100, will 0.1% weak-direction data error create about 0.1%, 1%, or 10% source error?');

%% Prepare the path-safe staged session after launch_lesson returns
disp('After launch_lesson returns, run these Command Window lines:');
disp('  p03Folder = fullfile(fileparts(which(''launch_lesson'')),''modules'',''03-see-conditioning-amplify-error'');');
disp('  addpath(p03Folder,''-begin''); edit(fullfile(p03Folder,''experiment.m''));');
disp('Keep that path until the fixed sections and interactive controls are finished.');

%% Baseline - run only the first section of experiment.m
disp('Open experiment.m in the Live Editor and run only the deterministic baseline section.');
disp('Inspect sensor-row separation first; then run the baseline changed-view section.');

%% One lever and changed view - condition number
disp('Run the Sweep 1 conditioning section. Describe only the growing source-error curve.');

%% Mechanism-first explanation after the changed view
disp('Run the Sweep 1 changed-view section and describe only the shrinking row angle.');
disp('After both observations, read Mechanism after observation in lesson.md for the equation.');

%% Reset, second lever, and changed view - perturbation direction
disp('Return to the baseline, then run the Sweep 2 perturbation-direction section.');
disp('Describe only the source-error curve while kappa and input-error size stay fixed.');

%% Second-lever changed view
disp('Run the Sweep 2 changed-view section, then compare amplification with the bound.');

%% Broken assumption
disp('Run the deliberately broken case in experiment.m.');
disp('Observe input error, source error, and residual before naming the failed assumption.');

%% Continue manually so each observation has one visible transition
disp('Do not use Run All on experiment.m during the guided lesson.');
disp('Run each experiment section separately and explain its one plot before advancing.');
disp('After every fixed section makes sense, type interactive to open the bounded controls.');
disp('Keep p03Folder on the path through the interactive session and executable checks.');

%% Check and teach back
disp('Run run_checks, answer checks.md, then teach back the mechanism before the symptom.');

%% Clean up after checks and the UI
disp('After run_checks passes and the UI is closed, clean up with: rmpath(p03Folder); clear p03Folder');
