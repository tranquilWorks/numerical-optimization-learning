# Checks: See Conditioning Amplify Error

## Observation check

The baseline measurement changes by only 0.1%, yet the inferred source changes by 10%. Explain this
using the weak gain `1/kappa` and error direction—not MATLAB syntax.

## Condition-lever check

In Sweep 1, error size and direction do not change. Why do the sensor-row angle shrink and the source
error grow together as `kappa` increases? Give the angle in degrees and identify which reported
quantities are dimensionless.

## Direction-lever check

At `kappa=100`, why can equal-size input errors have amplification anywhere from one to 100? Explain
why the condition number is a worst-case bound rather than the amplification of every perturbation.

## Broken-case check

Name the violated assumption precisely: a tiny residual against the perturbed measurements does not
certify closeness to the unknown true source. Distinguish relative input error, relative source error,
and residual in the one-ppm broken case.

## Limiting cases

- When `kappa=1`, why is the sensor matrix the identity and amplification one for every direction?
- With zero measurement error, what must remain unchanged even though geometric directional amplification stays defined?
- Why is one ppm a deliberate lesson-domain floor rather than a claim about the binary64 spacing threshold?
- With an error aligned to the strong direction, why is amplification one even when `kappa` is large?
- With an error aligned to the weak direction, why does amplification attain `kappa`?

## Transfer from P02

P02 showed a nonzero numerical update being rounded or absorbed. If that storage error becomes an
input to this calibrated sensor problem, which part comes from representation and which part comes
from conditioning? Would adding arithmetic precision change both?

## Executable checks

Run:

```matlab
run_checks
```

The checks cover determinism, independent gain and determinant identities, a direct 2-by-2 solve,
well-conditioned and zero-error limits, both independent sweeps, the broken residual diagnostic,
the one-ppm nonzero floor, malformed inputs, recovery after rejection, output finiteness, and the
maximum supported condition and perturbation bounds.

## Teach-back

Answer the guiding question without referring to MATLAB commands: What inputs, observable effects,
and failure modes matter when you see Conditioning Amplify Error? Use two sentences—mechanism first,
engineering consequence second.
