%% P01 - Watch Gradient Descent Converge or Diverge
% Guiding question:
% Why does gradient descent converge quickly, slowly, or not at all?
%
% Mental model:
% Gradient descent follows the local downhill direction. Step size controls how far it trusts that direction, while conditioning stretches the landscape and makes one safe step size inappropriate for another direction.

%% Read the baseline lesson
disp('Why does gradient descent converge quickly, slowly, or not at all?');
disp('Gradient descent follows the local downhill direction. Step size controls how far it trusts that direction, while conditioning stretches the landscape and makes one safe step size inappropriate for another direction.');

%% Run the deterministic experiment
experiment;

%% Open the live lever panel
% Move one control at a time and connect the visible change to the model.
interactive;
