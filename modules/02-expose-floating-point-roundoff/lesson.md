# Lesson: Expose Floating-Point Roundoff

## Guiding question

What inputs, observable effects, and failure modes matter when you expose Floating-Point Roundoff?

## Compounds on

P01 — Watch Gradient Descent Converge or Diverge. P01 treated each computed update as a change to
the iterate. P02 shows the representation limit: a valid nonzero update can be smaller than the
spacing around the current stored value, so the visible path can stall before the mathematical
update reaches zero.

## Mental model

Single-precision values occupy a binary grid. Within one normalized power-of-two interval,

```text
local spacing = 2^(floor(log2(x)) - 23)
next stored value = fl(stored value + stored update)
```

An update of 0.75 local ULP rounds to one ULP; an update below 0.5 local ULP can round to zero.
The ratio `update / local spacing` therefore predicts more than the absolute update alone.
At exactly half an ULP, round-to-nearest uses an even low-order significand bit, so parity can decide
the direction. The fixed examples avoid half-ULP ties; the interactive slider lets you inspect them.

## One prediction

Before seeing the baseline, predict whether 64 updates of 0.75 ULP will undershoot, match, or
overshoot the analytical change. Give the direction only; the plot will supply the magnitude.

## Baseline, one lever, and changed view

The baseline repeatedly adds `3*2^-25` to `single(1)`. The left view compares stored and analytical
accumulated change in value units. The right view reports signed cumulative error in starting-point
ULPs. Each requested 0.75-ULP update rounds upward to one ULP, so 64 additions create +16 ULPs of
error.

Sweep update size while the starting value and addition count remain fixed. First describe the
changed error and changed-step fraction. Then explain them: each addition is independently rounded
to a neighboring grid point, and the direction of that rounding repeats.

## Reset and move the second lever

Return to the baseline before sweeping accumulator magnitude. The absolute update is now fixed while
`x_0` moves from 0.25 to 16. Local spacing grows with magnitude, so one update moves from three ULPs,
to 0.75 ULP, to less than half a ULP. At the larger values every update is absorbed.

## Deliberately broken assumption

The broken case assumes floating-point addition is grouping invariant—or, equivalently here, that
many individually nonzero updates must eventually accumulate. Repeating a 0.25-ULP update 1024 times
leaves the stepwise accumulator at one. Grouping the same stored updates and rounding once moves by
256 ULPs. Algebra over real numbers did not change; the locations of rounding operations did.

## Controls and metrics

`interactive.m` exposes bounded controls for the starting power of two, update size measured in ULPs
at one, and addition count. Change one control, observe both views and the metric summary, explain the
mechanism, then reset before touching the next control.

Metrics include local spacing and update in value units, update/local-spacing ratio, changed and
absorbed step counts, observed versus expected change, and signed final error in starting ULPs.

## Common misconceptions

- Machine epsilon is not the spacing everywhere; spacing scales with magnitude.
- More iterations do not recover an update that is rounded away on every step.
- A small relative final error does not prove every intermediate update was represented.
- Real-number identities such as associativity do not automatically survive intermediate rounding.
- Exact half-ULP ties require the round-to-nearest, ties-to-even rule; “half always rounds up” is false.
- Single precision makes the effect visible here; double precision changes the scale, not the mechanism.

## Completion standard

Run `run_checks.m`, answer the interpretation questions in `checks.md`, and give a two-sentence
teach-back: mechanism first, consequence for an iterative method second. Static and independent
simulated checks are not MATLAB-runtime, UI, numerical-fidelity, bench, HIL, field, or production
evidence.
