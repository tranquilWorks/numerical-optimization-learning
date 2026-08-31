from __future__ import annotations

import json
from pathlib import Path
import re
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "modules/02-expose-floating-point-roundoff"
QUESTION = (
    "What inputs, observable effects, and failure modes matter when you expose "
    "Floating-Point Roundoff?"
)


def single(value: float) -> float:
    """Round a Python float to IEEE binary32 for an independent oracle."""
    return struct.unpack(">f", struct.pack(">f", value))[0]


def ordered_single_addition(start: float, increment: float, additions: int) -> list[float]:
    stored = single(start)
    stored_increment = single(increment)
    values = [stored]
    for _ in range(additions):
        stored = single(stored + stored_increment)
        values.append(stored)
    return values


class P02ModuleTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ROOT / "curriculum/modules.json").read_text(encoding="utf-8"))
        cls.module = next(module for module in cls.manifest["modules"] if module["id"] == "P02")

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
                "number": 2,
                "id": "P02",
                "title": "Expose Floating-Point Roundoff",
                "guiding_question": QUESTION,
                "phase": 1,
                "phase_title": "Numerical foundations",
                "slug": "expose-floating-point-roundoff",
                "folder": "modules/02-expose-floating-point-roundoff",
                "implementation_batch": "P02",
                "prerequisites": ["P01"],
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
        for marker in ("p01", "spacing", "ulp", "baseline", "mechanism", "teach-back"):
            self.assertIn(marker, combined)
        for placeholder in ("curriculum-scaffolded", "planned learner", "not implemented yet"):
            self.assertNotIn(placeholder, combined)

    def test_experiment_has_ordered_baseline_two_sweeps_and_broken_case(self):
        text = (FOLDER / "experiment.m").read_text(encoding="utf-8")
        lower = text.lower()
        headings = [
            lower.index("%% deterministic baseline"),
            lower.index("%% sweep 1 - update size"),
            lower.index("%% sweep 2 - accumulator magnitude"),
            lower.index("%% deliberately broken case"),
        ]
        self.assertEqual(headings, sorted(headings))
        self.assertGreaterEqual(lower.count("figure("), 4)
        self.assertGreaterEqual(lower.count("xlabel("), 7)
        self.assertGreaterEqual(lower.count("ylabel("), 7)
        for marker in (
            "value units",
            "starting-point ulp",
            "dimensionless ratio",
            "fprintf(",
            "grouping invariant",
            "assert(",
        ):
            self.assertIn(marker, lower)

    def test_model_is_bounded_deterministic_and_separate_from_presentation(self):
        text = (FOLDER / "model.m").read_text(encoding="utf-8").lower()
        for marker in (
            "validateattributes",
            "'<=',10000",
            "single(startvalue)",
            "single(increment)",
            "additions = double(additions)",
            "for k = 1:additions",
            "storedhistory(k+1) = storedhistory(k) + storedincrement",
            "referencechange",
            "observedchangehistory",
            "spacingatstart",
            "changedsteps",
        ):
            self.assertIn(marker, text)
        forbidden = re.compile(
            r"\b(?:figure|plot|subplot|uifigure|uiaxes|uislider|uispinner|rng|rand|randn|fopen|save|load)\s*\("
        )
        self.assertIsNone(forbidden.search(text))
        for opaque in ("fi(", "quantizer(", "numerictype(", "vpa(", "sym(", "digits("):
            self.assertNotIn(opaque, text)
        self.assertNotIn("cumsum(", text)
        compact = re.sub(r"\s+", "", text)
        for relation in (
            "referencechange=step*double(storedincrement)",
            "steproundoff(k)=observedstep-double(storedincrement)",
            "cumulativeerror(k+1)=cumulativeerror(k)+steproundoff(k)",
            "observedchangehistory=referencechange+cumulativeerror",
            "relativechangeerror=cumulativeerror(end)/expectedchange",
        ):
            self.assertIn(relation, compact)
        self.assertNotIn("cumulativeerror=storedvalue-referencevalue", compact)
        self.assertNotIn("cumulativeerror=observedchangehistory-referencechange", compact)

    def test_independent_binary32_oracle_covers_baseline_sweeps_and_broken_case(self):
        spacing = 2.0**-23
        baseline = ordered_single_addition(1.0, 3.0 * 2.0**-25, 64)
        self.assertEqual(baseline[-1] - baseline[0], 64.0 * spacing)
        self.assertEqual((baseline[-1] - (1.0 + 64.0 * 3.0 * 2.0**-25)) / spacing, 16.0)

        exact = ordered_single_addition(1.0, spacing, 64)
        swallowed = ordered_single_addition(1.0, 0.25 * spacing, 64)
        self.assertEqual(exact[-1], 1.0 + 64.0 * spacing)
        self.assertEqual(swallowed[-1], 1.0)

        fixed_increment = 3.0 * 2.0**-25
        self.assertEqual(ordered_single_addition(0.25, fixed_increment, 64)[-1], 0.25 + 64 * fixed_increment)
        self.assertEqual(ordered_single_addition(4.0, fixed_increment, 64)[-1], 4.0)

        broken = ordered_single_addition(1.0, 2.0**-25, 1024)
        rounded_once = single(1.0 + 1024.0 * 2.0**-25)
        self.assertEqual(broken[-1], 1.0)
        self.assertEqual(rounded_once, 1.0 + 256.0 * spacing)
        self.assertGreater(rounded_once, broken[-1])

        tiny_increment = 2.0**-40
        tiny = ordered_single_addition(2.0**20, tiny_increment, 1)
        self.assertEqual(tiny[-1] - tiny[0], 0.0)
        self.assertEqual((tiny[-1] - tiny[0]) - tiny_increment, -tiny_increment)

        wide = ordered_single_addition(2.0**-20, 2.0**20, 10_000)
        wide_step_error = sum(
            (wide[index + 1] - wide[index]) - 2.0**20 for index in range(10_000)
        )
        self.assertEqual(wide_step_error, -2.0**-20)

    def test_interactive_controls_are_bounded_meaningful_and_resettable(self):
        text = (FOLDER / "interactive.m").read_text(encoding="utf-8").lower()
        for marker in (
            "uifigure(",
            "uiaxes(",
            "uispinner(",
            "uislider(",
            "'limits',[-2 4]",
            "'limits',[0.1 2]",
            "'limits',[0 4096]",
            "roundfractionalvalues",
            "valuechangedfcn",
            "reset baseline",
            "modelfcn = @model",
            "modelfcn(startvalue,increment,additions)",
            "local spacing",
            "final error",
        ):
            self.assertIn(marker, text)
        compact = re.sub(r"\s+", "", text)
        self.assertEqual(compact.count("'roundfractionalvalues','on'"), 2)
        self.assertGreaterEqual(text.count("xlabel("), 2)
        self.assertGreaterEqual(text.count("ylabel("), 2)

    def test_checks_cover_limits_malformed_recovery_and_resource_bound(self):
        text = (FOLDER / "run_checks.m").read_text(encoding="utf-8").lower()
        self.assertGreaterEqual(text.count("assert("), 20)
        self.assertGreaterEqual(text.count("expectfailure("), 12)
        for marker in (
            "zero additions",
            "zero update",
            "independent ieee single-spacing",
            "grouping failure",
            "10000",
            "10001",
            "rejected call must not contaminate",
            "integer-class counts must normalize",
            "update below double spacing",
            "p02 checks passed",
        ):
            self.assertIn(marker, text)

    def test_tutor_material_asks_interpretation_and_teach_back(self):
        checks = (FOLDER / "checks.md").read_text(encoding="utf-8").lower()
        lesson = (FOLDER / "lesson.md").read_text(encoding="utf-8").lower()
        walkthrough = (FOLDER / "walkthrough.md").read_text(encoding="utf-8").lower()
        self.assertIn("## observation check", checks)
        self.assertIn("## limiting cases", checks)
        self.assertIn("## teach-back", checks)
        self.assertIn("grouping invariant", checks)
        self.assertIn("common misconceptions", lesson)
        self.assertIn("change only", walkthrough)
        self.assertIn("reset", walkthrough)

    def test_experiment_and_launch_preserve_staged_session_isolation(self):
        experiment = (FOLDER / "experiment.m").read_text(encoding="utf-8").lower()
        lesson_script = (FOLDER / "lesson.m").read_text(encoding="utf-8").lower()
        for global_side_effect in ("close all", "clc", "format long"):
            self.assertNotIn(global_side_effect, experiment)
        experiment_call = re.search(r"(?m)^\s*experiment\s*;\s*$", lesson_script)
        interactive_call = re.search(r"(?m)^\s*interactive\s*;\s*$", lesson_script)
        self.assertIsNotNone(experiment_call)
        self.assertIsNotNone(interactive_call)
        self.assertLess(experiment_call.start(), interactive_call.start())


if __name__ == "__main__":
    unittest.main()
