# Walkthrough: Expose Floating-Point Roundoff

Work one transition at a time. Do not open the interactive controls until both fixed sweeps make
sense.

1. Read the guiding question: What inputs, observable effects, and failure modes matter when you expose Floating-Point Roundoff?
2. Recall P01: a gradient step is an update to stored state. Predict once whether repeated 0.75-ULP updates will undershoot, match, or overshoot their analytical total.
3. Run only the deterministic baseline section of `experiment.m`. On the first plot, identify addition count and accumulated change in value units.
4. Inspect the signed-error plot in starting-point ULPs. State the observed +16-ULP error before reading its explanation.
5. Run Sweep 1. Hold `x_0=1` and 64 additions fixed while update size changes. Explain why 0.25 ULP changes no stored step and one ULP is exact.
6. Read the mechanism: the relevant input is update divided by local spacing, and each operation rounds separately.
7. Reset mentally to the baseline. Run Sweep 2 with one fixed absolute update while accumulator magnitude changes.
8. Explain why the same update is exact near 0.25, rounds upward near one, and is absorbed near four and sixteen.
9. Run the deliberately broken case. Name the violated assumption as grouping invariance of floating-point addition, not merely “roundoff happened.”
10. Open `interactive.m`. Change only the starting exponent, explain both plot changes, and press **Reset baseline**.
11. Change only update size, reset, then change only addition count. Tie each metric change to storage spacing or repeated rounding.
12. Run `run_checks.m` and answer the interpretation and limiting-case questions in `checks.md`.
13. Give a two-sentence teach-back: first explain the spacing/update mechanism; then explain how a P01-style iteration can stall with a nonzero mathematical update.

The stored arrays use value units, error uses starting-point ULPs, and update ratios are dimensionless.
Passing repository checks is static or independent simulated evidence; it does not establish MATLAB
runtime, UI rendering, numerical fidelity, or learner effectiveness.
