# Curriculum readiness audit

**Track:** Numerical Methods and Optimization

## Baseline conclusion

The repository has 24 uniquely identified modules in a six-phase, prerequisite-ordered sequence. P01 is the complete reference slice; P02-P24 are explicit non-runnable batch scaffolds. The learner flow is read → visualize → move one lever → visualize the delta → read/explain, followed by a broken case, checks, and teach-back.

Static structure and CLI behavior are verified in CI. MATLAB was not available during the 2026-08-11 baseline audit, so numerical execution, UI behavior, and instructional efficacy remain named validation gaps rather than implied evidence.

## Coverage and compounding order

### Phase 1: Numerical foundations

- **P01 — Watch Gradient Descent Converge or Diverge:** Why does gradient descent converge quickly, slowly, or not at all?
- **P02 — Expose Floating-Point Roundoff:** What inputs, observable effects, and failure modes matter when you expose Floating-Point Roundoff?
- **P03 — See Conditioning Amplify Error:** What inputs, observable effects, and failure modes matter when you see Conditioning Amplify Error?
- **P04 — Find Roots with Bracketing and Newton Steps:** What inputs, observable effects, and failure modes matter when you find Roots with Bracketing and Newton Steps?

### Phase 2: Approximation and calculus

- **P05 — Interpolate Sparse Data:** What inputs, observable effects, and failure modes matter when you interpolate Sparse Data?
- **P06 — Differentiate Noisy Measurements:** What inputs, observable effects, and failure modes matter when you differentiate Noisy Measurements?
- **P07 — Integrate a Function Numerically:** What inputs, observable effects, and failure modes matter when you integrate a Function Numerically?
- **P08 — Integrate an ODE with Competing Solvers:** What inputs, observable effects, and failure modes matter when you integrate an ODE with Competing Solvers?

### Phase 3: Linear algebra

- **P09 — Solve a Linear System:** What inputs, observable effects, and failure modes matter when you solve a Linear System?
- **P10 — Fit Data with Least Squares:** What inputs, observable effects, and failure modes matter when you fit Data with Least Squares?
- **P11 — Interpret Eigenvalues and Modes:** What inputs, observable effects, and failure modes matter when you interpret Eigenvalues and Modes?
- **P12 — Compress a Matrix with the SVD:** What inputs, observable effects, and failure modes matter when you compress a Matrix with the SVD?

### Phase 4: Optimization

- **P13 — Tune Gradient Descent:** What inputs, observable effects, and failure modes matter when you tune Gradient Descent?
- **P14 — Use Newton and Quasi-Newton Curvature:** What inputs, observable effects, and failure modes matter when you use Newton and Quasi-Newton Curvature?
- **P15 — Enforce Constraints:** What inputs, observable effects, and failure modes matter when you enforce Constraints?
- **P16 — Recognize Convex and Nonconvex Landscapes:** What inputs, observable effects, and failure modes matter when you recognize Convex and Nonconvex Landscapes?

### Phase 5: Identification and uncertainty

- **P17 — Estimate Model Parameters:** What inputs, observable effects, and failure modes matter when you estimate Model Parameters?
- **P18 — Regularize an Ill-Posed Fit:** What inputs, observable effects, and failure modes matter when you regularize an Ill-Posed Fit?
- **P19 — Compute Sensitivity to Inputs:** What inputs, observable effects, and failure modes matter when you compute Sensitivity to Inputs?
- **P20 — Propagate Uncertainty by Monte Carlo:** What inputs, observable effects, and failure modes matter when you propagate Uncertainty by Monte Carlo?

### Phase 6: Engineering optimization

- **P21 — Optimize a Trajectory:** What inputs, observable effects, and failure modes matter when you optimize a Trajectory?
- **P22 — Balance Multiple Objectives:** What inputs, observable effects, and failure modes matter when you balance Multiple Objectives?
- **P23 — Solve a Dynamic Program:** What inputs, observable effects, and failure modes matter when you solve a Dynamic Program?
- **P24 — Verify a Solver Against Independent Checks:** What inputs, observable effects, and failure modes matter when you verify a Solver Against Independent Checks?

## Batch readiness gates

A scaffold may become `implemented` only when it has a deterministic model, a sectioned experiment, two independent parameter sweeps, one deliberately broken case, interactive controls, interpretation-focused tutor text, numerical checks, focused static tests, and evidence that says exactly what did and did not run.
