# P03 — See Conditioning Amplify Error

**Track:** Numerical Methods and Optimization  
**Phase 1:** Numerical foundations  
**Status:** implemented

## Guiding question

What inputs, observable effects, and failure modes matter when you see Conditioning Amplify Error?

## Physical mental model

Two calibrated sensor channels estimate two source components. One source combination—the average—is
measured with unit gain. The orthogonal difference is measured with gain `1/kappa`. As `kappa` grows,
the two sensor sensitivity rows become nearly parallel: the measurements still capture the average,
but barely distinguish which source supplied it. A small measurement error can therefore matter very
differently depending on whether it points along the well-measured average or the weakly measured
difference. Make the prediction below before reading the exact amplification relation.

## Learning flow

1. Read how nearly redundant measurements hide one source direction.
2. Predict once whether a 0.1% weak-direction data error stays near 0.1% when `kappa=100`.
3. Use the printed session setup after `launch_lesson` returns, then run the deterministic baseline
   one Live Editor section at a time and compare sensor-row geometry with source error.
4. Sweep `kappa` while holding perturbation magnitude and direction fixed.
5. Explain the changed source error, then reset to the baseline.
6. Sweep perturbation direction while holding `kappa` and magnitude fixed.
7. Break the assumption that a tiny perturbed-data residual certifies an accurate source estimate.
8. Use the bounded controls, run independent checks, and give a mechanism-first teach-back.

## Mechanism to read after the changed view

For this lesson's unit-norm true source aligned with the strong direction, the exact measurement also
has unit norm. A relative measurement error of size `eta` at angle `theta` from the strong direction
toward the weak direction then gives

```text
relative source error = eta * sqrt(cos(theta)^2 + kappa^2*sin(theta)^2)
directional amplification <= kappa
```

Here `kappa` is the 2-norm condition number of the calibrated matrix and is dimensionless. Both source
components share source units, and both measurement channels share sensor units; arbitrary rescaling
or mixed units would require a fresh conditioning analysis.

## Baseline, independent levers, and broken case

- **Baseline:** `kappa=100`, `eta=0.001` (0.1% or 1000 ppm), and a weak-direction error produce
  10% relative source error and 100-fold amplification.
- **Sweep 1 — conditioning:** vary `kappa` from 1 to 1000 while error size and direction stay fixed.
- **Sweep 2 — error direction:** rotate the same 0.1% error from the strong direction to the weak
  direction while `kappa=100` stays fixed.
- **Broken case:** at `kappa=10^6`, one ppm of weak-direction error produces about 100% source error
  even though the reconstructed source fits the perturbed measurements to near machine precision.

The figures report sensor sensitivity coefficients (sensor units per source unit), source components
(source units), relative errors (percent), row angle (degrees), and dimensionless amplification,
condition number, and residual.

The bounded lesson domain accepts zero measurement error as a limiting case and nonzero relative
errors from one ppm (`1e-6`) through one percent. One ppm is a deliberate experiment and UI resolution,
not the binary64 spacing threshold; the floor keeps smaller storage effects from competing with the
conditioning mechanism at the displayed precision.

## Implementation contract

The completed module owns these files:

- `lesson.m` — notebook-style MATLAB sections (`%%`) and concise narrative.
- `interactive.m` — `uifigure` controls, plots, and immediate feedback.
- `model.m` — deterministic calculations separated from presentation.
- `experiment.m` — reproducible baseline, sweeps, and broken case.
- `lesson.md` — tutor-facing explanation and misconceptions.
- `walkthrough.md` — expected observations in order.
- `checks.md` and `run_checks.m` — conceptual and numerical completion checks.

The model uses fixed-size base MATLAB arithmetic and exposes its two gains directly; it does not call
`cond`, `svd`, a generic linear solver, or an inverse routine.

`launch_lesson` cleans up its temporary module path on return. `lesson.m` therefore prints a bounded
session handoff that derives the P03 folder from `which('launch_lesson')`, adds it while the learner
runs the fixed sections, UI, and `run_checks`, then removes it after checks pass and the UI closes. No
permanent MATLAB path change is made by the module.

## Prerequisite and evidence boundary

P02 showed how representation or measurement can introduce a small input perturbation. P03 separates
that error source from conditioning: the problem geometry determines how strongly the perturbation
appears in the inferred state. Repository tests retain static structure and an independent simulated
2-by-2 oracle only. MATLAB execution, plot rendering, UI behavior, numerical-fidelity validation,
learner effectiveness, bench, HIL, field, and production behavior require separate retained evidence.
