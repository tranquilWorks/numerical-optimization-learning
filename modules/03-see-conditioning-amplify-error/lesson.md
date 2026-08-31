# Lesson: See Conditioning Amplify Error

## Guiding question

What inputs, observable effects, and failure modes matter when you see Conditioning Amplify Error?

## Compounds on

P02 — Expose Floating-Point Roundoff. P02 made a small stored-input error visible. P03 asks a separate
question: after an error enters the data, how much can the problem itself amplify it? Better arithmetic
can reduce the perturbation, but it cannot remove sensitivity built into nearly redundant measurements.

## Mental model

Imagine two calibrated sensors trying to recover two source amplitudes. They measure the source
average strongly but the source difference weakly. As the two sensor sensitivity rows become nearly
parallel, they keep agreeing about the average while losing the ability to distinguish which source
supplied it. Before seeing an equation, predict whether a small error aimed along that weak difference
will remain small in the inferred source.

## One prediction

Before the baseline, predict whether 0.1% weak-direction measurement error at `kappa=100` will create
about 0.1%, 1%, or 10% source error. Choose one; the plots will show the geometry and magnitude.

## Baseline, one lever, and changed view

The deterministic baseline uses `kappa=100`, `eta=0.001`, and `theta=90 degrees`. The sensor-row view
shows two nearly parallel sensitivity vectors. The source view shows 10% relative error even though
the data moved only 0.1%. The directional amplification is 100, exactly reaching the condition bound.

Sweep `kappa` while perturbation size and direction remain fixed. First observe the growing source
error and shrinking row angle. Do not read the mechanism until you have described both changes.

## Mechanism after observation

Define the unit average and difference directions

```text
q_strong = [1; 1] / sqrt(2)
q_weak   = [1;-1] / sqrt(2)
A = q_strong*q_strong' + (1/kappa)*q_weak*q_weak'
```

The gains are now visible: `A*q_strong=q_strong`, while `A*q_weak=q_weak/kappa`. Reconstructing the
weak measured difference therefore multiplies its error by `kappa`. The sensor rows are separated by
`2*atan(1/kappa)`, so the shrinking angle and growing worst-direction error have the same cause.

For this lesson's unit-norm true source aligned with the strong direction, the exact measurement also
has unit norm. For a relative data error of size `eta` at angle `theta` from the strong direction
toward the weak direction,

```text
relative source error = eta * sqrt(cos(theta)^2 + kappa^2*sin(theta)^2)
```

The realized amplification lies between one and `kappa`. The condition number is a worst-case bound,
not a prediction that every error is multiplied by `kappa`.

## Reset and move the second lever

Return to `kappa=100` and the same 0.1% error size. Rotate only its direction. A strong-direction error
has amplification one; a weak-direction error has amplification 100. Intermediate directions use only
part of the worst-case sensitivity. Direction changes realized amplification without changing the
condition number or input-error magnitude.

## Deliberately broken assumption

The broken case challenges “a tiny residual against the perturbed measurements certifies closeness to
the unknown true source.” At `kappa=10^6`, one ppm of weak-direction input error creates approximately
100% source error. The inferred source still fits the perturbed data to near machine precision because
it is an accurate solution to the wrong nearby input. Residual measures fit to supplied data; forward
error measures distance from the unknown truth.

## Controls and metrics

`interactive.m` exposes bounded controls for `log10(kappa)`, measurement error in parts per million,
and error angle in degrees. Change one control, observe the sensor-row and source views, explain the
mechanism, and reset before touching the next control.

Because `launch_lesson` removes its temporary module path when it returns, follow the printed session
handoff before running `experiment.m` sections. It derives `p03Folder` from `which('launch_lesson')`,
adds that folder for the staged experiment, UI, and `run_checks`, then tells you to remove it after
checks pass and the UI closes. This keeps callbacks and checks resolvable without a permanent path
change.

The bounded lesson model accepts zero error for the limiting case or a nonzero error of at least one
ppm. One ppm is a chosen experiment and UI resolution, not the binary64 spacing threshold. It keeps
smaller storage effects from competing with the conditioning mechanism at the displayed precision;
P02 is the place to vary representation effects directly.

Metrics include sensor-row separation (degrees), relative input and source errors (percent),
directional amplification, the dimensionless condition bound, and the relative residual against the
perturbed measurements. Source axes use source units; sensitivity axes use sensor units per source
unit. The condition number is valid for this calibrated common-unit scaling.

## Common misconceptions

- A large condition number is a property of this input-output problem, not proof that the solver failed.
- `kappa` is a worst-case amplification bound; strong-direction errors can still amplify by only one.
- A small residual shows consistency with supplied data, not closeness to an unknown true source.
- Small determinant alone is not a scale-independent conditioning test; this lesson exposes normalized gains.
- More digits can shrink the P02-style perturbation but do not change the matrix's weak direction.
- Changing units or scaling can change a numerical condition number, so compare like units or normalize first.

## Completion standard

Run `run_checks.m`, answer the interpretation questions in `checks.md`, and give a two-sentence
teach-back: mechanism first, engineering consequence second. Static and independent simulated checks
are not MATLAB-runtime, UI, numerical-fidelity, learner-protocol, bench, HIL, field, or production evidence.
