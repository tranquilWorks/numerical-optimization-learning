# Checks: Expose Floating-Point Roundoff

## Observation check

At `x_0=1`, why does a 0.75-ULP update create positive signed error while a 1.25-ULP update creates
negative signed error? Answer in terms of the neighboring storage grid points, not MATLAB syntax.

## Scale-lever check

The fixed update in Sweep 2 does not change. Why is it resolved near `x_0=0.25` but absorbed near
`x_0=4`? Name the quantity that changes and give its units.

## Broken-case check

Name the violated assumption precisely: floating-point addition is not grouping invariant because
each ordered update is rounded before the next. Explain why “1024 nonzero updates must eventually
move the accumulator” fails in this case.

## Limiting cases

- With zero additions, what must the stored trace and final error be?
- With a zero update, what must remain constant?
- Why does an exactly representable one-ULP update accumulate without error while the trace remains in one power-of-two interval?

## Transfer to P01

Describe how a gradient-descent iterate can appear converged even when its mathematical gradient
update is nonzero. What comparison would distinguish representation-induced stagnation from a truly
zero update?

## Executable checks

Run:

```matlab
run_checks
```

The checks cover determinism, analytical spacing, exact and absorbed limits, both sweeps, the broken
grouping case, malformed inputs, recovery after rejection, output finiteness, and the 10,000-addition
resource bound.

## Teach-back

Answer the guiding question without referring to MATLAB commands: What inputs, observable effects,
and failure modes matter when you expose Floating-Point Roundoff? Use two sentences—mechanism first,
consequence second.
