# Walkthrough: See Conditioning Amplify Error

Work one transition at a time. Do not open the interactive controls until both fixed sweeps make
sense.

1. Read the guiding question: What inputs, observable effects, and failure modes matter when you see Conditioning Amplify Error?
2. Recall P02: small errors can enter stored or measured inputs. Predict once whether 0.1% weak-direction error at `kappa=100` produces about 0.1%, 1%, or 10% source error.
3. After `launch_lesson` returns, run its printed `p03Folder` and `addpath` setup, which also opens `experiment.m`. Do not use **Run All**. Run only the deterministic baseline section and identify the two sensor sensitivity rows and their separation angle in degrees.
4. Run the baseline changed-view section. State the observed 10% source error and 100-fold amplification before reading the explanation.
5. Run Sweep 1. Hold error size at 0.1% and direction at 90 degrees while `kappa` changes; describe the growing source error.
6. Run the Sweep 1 changed-view section and describe the shrinking row angle. Then read the mechanism: the weak measurement gain is `1/kappa`, so reconstruction multiplies that directional error by `kappa`.
7. Reset mentally to `kappa=100`. Run Sweep 2 with input-error magnitude fixed while its direction rotates from strong to weak; describe the source-error curve.
8. Run the Sweep 2 changed-view section. Explain why amplification ranges from one to 100 although the condition number never changes. Name `kappa` as a worst-case bound, not a guaranteed error multiplier.
9. Run the deliberately broken case. Name the violated assumption precisely: a tiny residual against perturbed data does not certify closeness to the unknown true source.
10. Type `interactive` only after the fixed views make sense. Change only the condition exponent, explain both UI views, and press **Reset baseline**.
11. Change only measurement-error ppm, reset, then change only error angle. Tie every change to perturbation size, weak gain, or directional alignment. Zero is the limiting case; one ppm is the smallest supported nonzero error.
12. Run `run_checks.m` and answer the observation, limiting-case, residual, and P02-transfer questions in `checks.md`.
13. Give a two-sentence teach-back: first explain the weak-direction mechanism; then explain why a small input error or residual can coexist with a large state error.
14. Close the P03 UI, then run the printed `rmpath(p03Folder); clear p03Folder` cleanup so the session leaves no persistent MATLAB path entry.

Source axes use source units; sensitivity axes use sensor units per source unit. Relative errors are
percentages, angles are degrees, and condition number, amplification, and relative residual are
dimensionless. Passing repository checks is static or independent simulated evidence; it does not
establish MATLAB runtime, UI rendering, numerical fidelity, or learner effectiveness.
