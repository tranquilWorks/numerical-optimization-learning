# Lesson: Watch Gradient Descent Converge or Diverge

## Guiding question

Why does gradient descent converge quickly, slowly, or not at all?

## Mental model

Gradient descent follows the local downhill direction. Step size controls how far it trusts that direction, while conditioning stretches the landscape and makes one safe step size inappropriate for another direction.

## What to manipulate

Use `interactive.m`. Change one lever at a time before combining effects.

## First observation

Increase the condition number and watch the path zig-zag. Increase step size until convergence accelerates, then crosses into oscillation and divergence.

## Common mistakes

- A larger step is not always faster.
- Slow convergence can be a property of coordinates and conditioning, not the objective alone.
- A smooth plot does not prove a numerical method is stable.

## Completion standard

The learner can explain the baseline, identify what each lever changes, diagnose the deliberately broken case, and pass `run_checks.m`.
