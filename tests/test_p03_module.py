from __future__ import annotations

import json
import math
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "modules/03-see-conditioning-amplify-error"
QUESTION = (
    "What inputs, observable effects, and failure modes matter when you see "
    "Conditioning Amplify Error?"
)


def solve_two_by_two(matrix: list[list[float]], rhs: list[float]) -> list[float]:
    """Solve a fixed 2-by-2 system by Cramer's rule for an independent oracle."""
    determinant = matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]
    return [
        (matrix[1][1] * rhs[0] - matrix[0][1] * rhs[1]) / determinant,
        (-matrix[1][0] * rhs[0] + matrix[0][0] * rhs[1]) / determinant,
    ]


def norm(vector: list[float]) -> float:
    return math.sqrt(sum(value * value for value in vector))


def independent_case(kappa: float, error_fraction: float, angle_degrees: float) -> dict[str, float]:
    """Build and solve the calibrated sensor system without the MATLAB modal path."""
    inverse_kappa = 1.0 / kappa
    matrix = [
        [0.5 * (1.0 + inverse_kappa), 0.5 * (1.0 - inverse_kappa)],
        [0.5 * (1.0 - inverse_kappa), 0.5 * (1.0 + inverse_kappa)],
    ]
    scale = 1.0 / math.sqrt(2.0)
    strong = [scale, scale]
    weak = [scale, -scale]
    angle = math.radians(angle_degrees)
    delta = [
        error_fraction * (math.cos(angle) * strong[index] + math.sin(angle) * weak[index])
        for index in range(2)
    ]
    perturbed = [strong[index] + delta[index] for index in range(2)]
    estimated = solve_two_by_two(matrix, perturbed)
    source_error = norm([estimated[index] - strong[index] for index in range(2)])
    input_error = norm(delta)
    predicted = [
        matrix[row][0] * estimated[0] + matrix[row][1] * estimated[1]
        for row in range(2)
    ]
    relative_residual = norm(
        [predicted[index] - perturbed[index] for index in range(2)]
    ) / norm(perturbed)
    geometric_amplification = math.sqrt(
        math.cos(angle) ** 2 + kappa**2 * math.sin(angle) ** 2
    )
    return {
        "input_error": input_error,
        "source_error": source_error,
        "amplification": geometric_amplification,
        "residual": relative_residual,
        "row_angle_degrees": math.degrees(2.0 * math.atan(1.0 / kappa)),
    }


class P03ModuleTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ROOT / "curriculum/modules.json").read_text(encoding="utf-8"))
        cls.module = next(module for module in cls.manifest["modules"] if module["id"] == "P03")

    def test_permanent_manifest_identity_and_complete_artifacts(self):
        self.assertEqual(
            {
                "number": self.module["number"],
                "id": self.module["id"],
                "title": self.module["title"],
                "guiding_question": self.module["guiding_question"],
                "phase": self.module["phase"],
                "phase_title": self.module["phase_title"],
                "slug": self.module["slug"],
                "folder": self.module["folder"],
                "implementation_batch": self.module["implementation_batch"],
                "prerequisites": self.module["prerequisites"],
            },
            {
                "number": 3,
                "id": "P03",
                "title": "See Conditioning Amplify Error",
                "guiding_question": QUESTION,
                "phase": 1,
                "phase_title": "Numerical foundations",
                "slug": "see-conditioning-amplify-error",
                "folder": "modules/03-see-conditioning-amplify-error",
                "implementation_batch": "P03",
                "prerequisites": ["P02"],
            },
        )
        self.assertEqual(self.module["status"], "implemented")
        self.assertEqual(self.module["evidence_level"], "simulated")
        required = {
            "README.md",
            "lesson.m",
            "model.m",
            "experiment.m",
            "interactive.m",
            "lesson.md",
            "walkthrough.md",
            "checks.md",
            "run_checks.m",
        }
        self.assertTrue(required <= {path.name for path in FOLDER.iterdir() if path.is_file()})

    def test_guiding_question_prerequisite_and_concept_flow_are_explicit(self):
        for name in ("README.md", "lesson.m", "lesson.md", "walkthrough.md"):
            with self.subTest(file=name):
                self.assertIn(QUESTION, (FOLDER / name).read_text(encoding="utf-8"))
        combined = "\n".join(
            (FOLDER / name).read_text(encoding="utf-8").lower()
            for name in ("README.md", "lesson.m", "lesson.md", "walkthrough.md", "checks.md")
        )
        for marker in (
            "p02",
            "sensor",
            "weak",
            "condition",
            "baseline",
            "mechanism",
            "teach-back",
        ):
            self.assertIn(marker, combined)
        for placeholder in (
            "curriculum-scaffolded",
            "planned learner sequence",
            "not implemented yet",
            "intentionally refuses",
        ):
            self.assertNotIn(placeholder, combined)

    def test_experiment_has_baseline_two_independent_sweeps_and_broken_case(self):
        text = (FOLDER / "experiment.m").read_text(encoding="utf-8")
        lower = text.lower()
        headings = [
            lower.index("%% deterministic baseline"),
            lower.index("%% sweep 1 - conditioning"),
            lower.index("%% sweep 2 - perturbation direction"),
            lower.index("%% deliberately broken case"),
        ]
        self.assertEqual(headings, sorted(headings))
        self.assertGreaterEqual(lower.count("figure("), 7)
        self.assertGreaterEqual(lower.count("xlabel("), 7)
        self.assertGreaterEqual(lower.count("ylabel("), 7)
        self.assertNotIn("subplot(", lower)
        for marker in (
            "sensor units / source unit",
            "source units",
            "relative error (%)",
            "degrees",
            "dimensionless",
            "fprintf(",
            "tiny residual",
            "assert(",
        ):
            self.assertIn(marker, lower)
        self.assertIn("model(conditionvalues(i),baselineerrorfraction,90)", lower)
        self.assertIn(
            "model(baselinecondition,baselineerrorfraction,directionangles(i))", lower
        )

    def test_model_is_bounded_deterministic_transparent_and_presentation_free(self):
        text = (FOLDER / "model.m").read_text(encoding="utf-8").lower()
        for marker in (
            "validateattributes",
            "'<=',1e6",
            "'<=',0.01",
            "'>=',-90",
            "minimumnonzerorelativemeasurementerror = 1e-6",
            "minimumforinputclass = cast(",
            "p03:model:belowminimumerror",
            "parameterdirections",
            "systemmatrix",
            "measurementdirectioncoordinates",
            "estimateddirectioncoordinates",
            "predictedmeasurement = systemmatrix*estimatedstate",
            "directionalamplification",
            "rowseparationdegrees",
            "conditionbound",
        ):
            self.assertIn(marker, text)
        forbidden_presentation = re.compile(
            r"\b(?:figure|plot|subplot|uifigure|uiaxes|uislider|uispinner)\s*\("
        )
        self.assertIsNone(forbidden_presentation.search(text))
        forbidden_state = re.compile(
            r"\b(?:rng|rand|randn|fopen|fwrite|save|load|webread|urlread|global)\s*\("
        )
        self.assertIsNone(forbidden_state.search(text))
        forbidden_black_box = re.compile(
            r"\b(?:cond|rcond|svd|inv|pinv|linsolve|mldivide|eig)\s*\("
        )
        self.assertIsNone(forbidden_black_box.search(text))
        self.assertNotIn("\\", text)
        compact = re.sub(r"\s+", "", text)
        for relation in (
            "systemmatrix=parameterdirections*[10;01/conditionnumber]*parameterdirections'",
            "measurementdirectioncoordinates=parameterdirections'*perturbedmeasurement",
            "estimatedstate=parameterdirections*estimateddirectioncoordinates",
            "parametererror=estimatedstate-truestate",
            "predictedmeasurement=systemmatrix*estimatedstate",
            "conditionbound=conditionnumber*relativeinputerror",
            "rowseparationdegrees=2*atand(1/conditionnumber)",
        ):
            self.assertIn(relation, compact)

    def test_independent_oracle_covers_baseline_sweeps_limits_and_broken_case(self):
        baseline = independent_case(100.0, 0.001, 90.0)
        self.assertAlmostEqual(baseline["input_error"], 0.001, places=14)
        self.assertAlmostEqual(baseline["source_error"], 0.1, places=12)
        self.assertAlmostEqual(baseline["amplification"], 100.0, places=12)
        self.assertAlmostEqual(
            baseline["row_angle_degrees"], math.degrees(2.0 * math.atan(0.01)), places=13
        )
        self.assertLess(baseline["residual"], 1e-14)

        condition_values = [1.0, 3.0, 10.0, 30.0, 100.0, 300.0, 1000.0]
        condition_errors = [
            independent_case(kappa, 0.001, 90.0)["source_error"]
            for kappa in condition_values
        ]
        for observed, kappa in zip(condition_errors, condition_values, strict=True):
            self.assertAlmostEqual(observed, 0.001 * kappa, places=10)

        direction_angles = [0.0, 15.0, 30.0, 45.0, 60.0, 75.0, 90.0]
        direction_gains = [
            independent_case(100.0, 0.001, angle)["amplification"]
            for angle in direction_angles
        ]
        self.assertAlmostEqual(direction_gains[0], 1.0, places=13)
        self.assertAlmostEqual(direction_gains[-1], 100.0, places=12)
        self.assertTrue(all(left < right for left, right in zip(direction_gains, direction_gains[1:])))

        for angle in (0.0, 37.0, 90.0):
            well_conditioned = independent_case(1.0, 0.001, angle)
            self.assertAlmostEqual(
                well_conditioned["source_error"], well_conditioned["input_error"], places=14
            )
            self.assertAlmostEqual(well_conditioned["amplification"], 1.0, places=14)
        self.assertLess(independent_case(100.0, 0.0, 47.0)["source_error"], 1e-13)
        self.assertAlmostEqual(
            independent_case(1e6, 0.001, 0.0)["source_error"], 0.001, places=10
        )

        broken = independent_case(1e6, 1e-6, 90.0)
        # One ppm is the model's smallest supported nonzero perturbation.
        self.assertAlmostEqual(broken["input_error"], 1e-6, places=14)
        self.assertAlmostEqual(broken["source_error"], 1.0, places=7)
        self.assertAlmostEqual(broken["amplification"], 1e6, places=6)
        self.assertLess(broken["residual"], 1e-10)

    def test_interactive_controls_are_bounded_meaningful_resettable_and_path_safe(self):
        text = (FOLDER / "interactive.m").read_text(encoding="utf-8").lower()
        for marker in (
            "uifigure(",
            "uiaxes(",
            "uislider(",
            "uispinner(",
            "'limits',[0 6]",
            "'limits',[0 10000]",
            "'limits',[0 90]",
            "roundfractionalvalues",
            "valuechangedfcn",
            "reset baseline",
            "modelfcn = @model",
            "modelfcn(conditionnumber,relativeerror,angledegrees)",
            "row angle",
            "directional amplification",
            "residual",
        ):
            self.assertIn(marker, text)
        self.assertGreaterEqual(text.count("xlabel("), 2)
        self.assertGreaterEqual(text.count("ylabel("), 2)

    def test_checks_cover_invariants_malformed_recovery_compatibility_and_bounds(self):
        text = (FOLDER / "run_checks.m").read_text(encoding="utf-8").lower()
        self.assertGreaterEqual(text.count("assert("), 30)
        self.assertGreaterEqual(text.count("expectfailure("), 20)
        for marker in (
            "cramer-rule",
            "determinant identity",
            "kappa=1",
            "zero measurement error",
            "one-ppm nonzero floor",
            "strong-direction amplification",
            "weak-direction amplification",
            "condition bound",
            "one part per million",
            "maximum supported fixed-size",
            "1e6+1",
            "0.010001",
            "0.5e-6",
            "rejected call must not contaminate",
            "integer-class condition and angle inputs",
            "single-precision nominal one-ppm boundary",
            "p03 checks passed",
        ):
            self.assertIn(marker, text)

    def test_tutor_material_asks_interpretation_transfer_and_teach_back(self):
        checks = (FOLDER / "checks.md").read_text(encoding="utf-8").lower()
        lesson = (FOLDER / "lesson.md").read_text(encoding="utf-8").lower()
        walkthrough = (FOLDER / "walkthrough.md").read_text(encoding="utf-8").lower()
        for heading in (
            "## observation check",
            "## condition-lever check",
            "## direction-lever check",
            "## broken-case check",
            "## limiting cases",
            "## transfer from p02",
            "## teach-back",
        ):
            self.assertIn(heading, checks)
        self.assertIn("common misconceptions", lesson)
        self.assertIn("worst-case bound", lesson)
        self.assertIn("unit-norm true source aligned with the strong direction", lesson)
        self.assertIn(
            "unit-norm true source aligned with the strong direction",
            (FOLDER / "README.md").read_text(encoding="utf-8").lower(),
        )
        self.assertIn("ui, and `run_checks`", lesson)
        self.assertIn("change only", walkthrough)
        self.assertIn("reset", walkthrough)

        lesson_script = (FOLDER / "lesson.m").read_text(encoding="utf-8").lower()
        pre_prediction_script = lesson_script.split("%% predict once", maxsplit=1)[0]
        self.assertNotIn("multiplies its error by kappa", pre_prediction_script)
        self.assertNotIn("relative source error =", lesson_script)
        self.assertNotIn("multiplies its error by kappa", lesson_script)
        self.assertIn("lesson.md for the equation", lesson_script)
        self.assertIn("sweep 1 changed-view section", lesson_script)
        self.assertIn("sweep 2 changed-view section", lesson_script)
        lesson_markdown = (FOLDER / "lesson.md").read_text(encoding="utf-8").lower()
        pre_prediction_markdown = lesson_markdown.split("## one prediction", maxsplit=1)[0]
        self.assertNotIn("relative source error =", pre_prediction_markdown)
        ordered_markers = [
            lesson_script.index("%% predict once"),
            lesson_script.index("%% baseline"),
            lesson_script.index("%% one lever"),
            lesson_script.index("%% mechanism-first"),
            lesson_script.index("%% reset, second lever"),
            lesson_script.index("%% broken assumption"),
        ]
        self.assertEqual(ordered_markers, sorted(ordered_markers))

    def test_experiment_and_launch_preserve_staged_session_isolation(self):
        experiment = (FOLDER / "experiment.m").read_text(encoding="utf-8").lower()
        lesson_script = (FOLDER / "lesson.m").read_text(encoding="utf-8").lower()
        launcher = (ROOT / "launch_lesson.m").read_text(encoding="utf-8").lower()
        for global_side_effect in ("close all", "clc", "format long", "rng(", "global "):
            self.assertNotIn(global_side_effect, experiment)
        experiment_call = re.search(r"(?m)^\s*experiment\s*;\s*$", lesson_script)
        interactive_call = re.search(r"(?m)^\s*interactive\s*;\s*$", lesson_script)
        self.assertIsNone(experiment_call)
        self.assertIsNone(interactive_call)
        self.assertIn("do not use run all", lesson_script)
        self.assertIn("run each experiment section separately", lesson_script)
        self.assertIn("type interactive", lesson_script)
        self.assertIn("oncleanup(@() rmpath(folder))", re.sub(r"\s+", " ", launcher))
        self.assertIn("which(''launch_lesson'')", lesson_script)
        self.assertIn("addpath(p03folder,''-begin'')", lesson_script)
        self.assertIn("edit(fullfile(p03folder,''experiment.m''))", lesson_script)
        self.assertIn("rmpath(p03folder)", lesson_script)
        self.assertLess(lesson_script.index("run run_checks"), lesson_script.index("rmpath(p03folder)"))
        self.assertIn("after run_checks passes and the ui is closed", lesson_script)
        self.assertIsNone(re.search(r"(?m)^\s*addpath\s*\(", lesson_script))

    def test_owned_module_text_files_have_one_terminal_newline(self):
        for path in sorted(FOLDER.iterdir()):
            if path.suffix not in {".m", ".md"}:
                continue
            with self.subTest(file=path.name):
                content = path.read_bytes()
                self.assertTrue(content.endswith(b"\n"))
                self.assertFalse(content.endswith(b"\n\n"))


if __name__ == "__main__":
    unittest.main()
