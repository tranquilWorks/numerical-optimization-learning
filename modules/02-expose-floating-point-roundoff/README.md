# P02 — Expose Floating-Point Roundoff

**Track:** Numerical Methods and Optimization  
**Phase 1:** Numerical foundations  
**Status:** implemented

## Guiding question

What inputs, observable effects, and failure modes matter when you expose Floating-Point Roundoff?

## Physical mental model

Floating-point numbers form a scale-dependent grid, not a continuous number line. Near a stored
value `x`, `eps(single(x))` is the distance to the next larger single-precision number. An update
smaller than that spacing must be rounded, and an update smaller than half the spacing can disappear.
Repeated rounding can therefore bias or stall an otherwise valid iteration.

For normalized single precision in one fixed power-of-two interval,

```text
spacing(x) = 2^(floor(log2(x)) - 23)
stored next value = fl(stored x + stored update)
```

The lesson uses single precision so the gaps become visible with small, readable examples. The same
mechanism occurs in double precision with a finer grid.

## Learning flow

1. Read how local spacing changes with accumulator magnitude.
2. Run the deterministic baseline and compare the stored trace with an analytical reference.
3. Sweep update size while holding the accumulator and operation count fixed.
4. Explain the changed error before resetting the baseline.
5. Sweep accumulator magnitude while holding the update and operation count fixed.
6. Break the assumption that many nonzero updates must eventually change the stored value.
7. Use the controls, run independent checks, and give a mechanism-first teach-back.

## Baseline, levers, and broken case

- **Baseline:** add `3*2^-25` to `single(1)` 64 times. The requested update is 0.75 local ULP,
  so each stored step rounds upward to one ULP.
- **Sweep 1 — update size:** vary the update from 0.25 to 1.75 ULP at `x_0 = 1`.
- **Sweep 2 — accumulator magnitude:** apply one fixed update at `x_0 = 0.25, 1, 4, 16`.
- **Broken case:** add a 0.25-ULP update 1024 times. Ordered addition remains stuck at one,
  although adding the grouped total once changes the stored value.

The two plots report accumulated change in value units and signed error in starting-point ULPs.
The interactive controls bound start exponent, update size, and addition count.

## Implementation contract

The completed module owns these files:

- `lesson.m` — notebook-style MATLAB sections (`%%`) and concise narrative.
- `interactive.m` — `uifigure` controls, plots, and immediate feedback.
- `model.m` — deterministic calculations separated from presentation.
- `experiment.m` — reproducible baseline, sweeps, and broken case.
- `lesson.md` — tutor-facing explanation and misconceptions.
- `walkthrough.md` — expected observations in order.
- `checks.md` and `run_checks.m` — conceptual and numerical completion checks.

Prefer base MATLAB. Optional toolbox comparisons may be added only after the underlying operation is visible.

## Prerequisite and evidence boundary

P01 showed that an iterative update can converge, oscillate, or diverge. P02 adds a representation
limit: even a mathematically nonzero P01-style update can leave a stored state unchanged when it is
smaller than local spacing. The module has no toolbox dependency. Repository tests retain static and
independent simulated evidence only; MATLAB execution, plot rendering, UI behavior, numerical-fidelity
validation, and learner effectiveness require separate retained evidence.
