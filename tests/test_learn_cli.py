from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LearnCliTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ROOT / "curriculum/modules.json").read_text(encoding="utf-8"))

    def build_fixture(self, temporary: str) -> Path:
        fixture = Path(temporary) / "repo"
        shutil.copytree(ROOT / "bin", fixture / "bin")
        shutil.copytree(ROOT / "curriculum", fixture / "curriculum")
        manifest = json.loads((fixture / "curriculum/modules.json").read_text(encoding="utf-8"))
        for module in manifest["modules"]:
            source = ROOT / module["folder"]
            target = fixture / module["folder"]
            target.mkdir(parents=True, exist_ok=True)
            for name in ("README.md", "lesson.md", "walkthrough.md", "checks.md"):
                shutil.copy2(source / name, target / name)
            if (source / "run_checks.m").exists():
                shutil.copy2(source / "run_checks.m", target / "run_checks.m")
        return fixture

    def run_in_fixture(self, fixture: Path, *args: str) -> subprocess.CompletedProcess[str]:
        environment = os.environ.copy()
        environment["PYTHONDONTWRITEBYTECODE"] = "1"
        return subprocess.run(
            [str(fixture / "bin/learn"), *args],
            cwd=fixture,
            text=True,
            capture_output=True,
            env=environment,
            timeout=10,
        )

    def run_cli(self, *args: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as temporary:
            return self.run_in_fixture(self.build_fixture(temporary), *args)

    def test_status_and_list(self):
        status = self.run_cli("status")
        self.assertEqual(status.returncode, 0, status.stderr)
        implemented = sum(module["status"] == "implemented" for module in self.manifest["modules"])
        self.assertIn(f"{self.manifest['module_count']} total, {implemented} implemented", status.stdout)
        listing = self.run_cli("list")
        self.assertEqual(listing.returncode, 0, listing.stderr)
        self.assertEqual(
            len([line for line in listing.stdout.splitlines() if line.strip()]),
            self.manifest["module_count"],
        )

    def test_reference_starts_and_current_scaffold_refuses(self):
        reference = self.run_cli("start", "P01")
        self.assertEqual(reference.returncode, 0, reference.stderr)
        self.assertIn("Guiding question:", reference.stdout)
        scaffolded = [module for module in self.manifest["modules"] if module["status"] == "scaffolded"]
        if scaffolded:
            scaffold = self.run_cli("start", scaffolded[0]["id"])
            self.assertEqual(scaffold.returncode, 2)
            self.assertIn("Activate its governed implementation batch", scaffold.stdout)

    def test_p02_starts_and_exposes_checks_permanently(self):
        started = self.run_cli("start", "P02")
        self.assertEqual(started.returncode, 0, started.stderr)
        self.assertIn("P02 — Expose Floating-Point Roundoff", started.stdout)
        self.assertIn(
            "Guiding question: What inputs, observable effects, and failure modes matter when you expose Floating-Point Roundoff?",
            started.stdout,
        )
        checked = self.run_cli("check", "P02")
        self.assertEqual(checked.returncode, 0, checked.stderr)
        self.assertIn("run_module_checks('P02')", checked.stdout)

    def test_p02_completion_record_persists_and_scaffold_refusal_is_non_mutating(self):
        # Checks and teach-back judgment are manual gates; the CLI only records their result.
        teach_back = (
            "Local spacing sets which updates are representable. "
            "Repeated rounding can stall a nonzero mathematical update."
        )
        with tempfile.TemporaryDirectory() as temporary:
            fixture = self.build_fixture(temporary)
            completed = self.run_in_fixture(
                fixture,
                "complete",
                "P02",
                "--note",
                teach_back,
            )
            self.assertEqual(completed.returncode, 0, completed.stderr)
            self.assertIn("Marked P02 complete.", completed.stdout)

            state_path = fixture / ".learning/progress.json"
            completed_state = json.loads(state_path.read_text(encoding="utf-8"))
            self.assertEqual(completed_state["current"], "P02")
            self.assertEqual(completed_state["completed"], {"P02": True})
            self.assertEqual(completed_state["notes"], {"P02": teach_back})

            scaffolded = [
                module for module in self.manifest["modules"] if module["status"] == "scaffolded"
            ]
            if scaffolded:
                retained_bytes = state_path.read_bytes()
                refused = self.run_in_fixture(fixture, "complete", scaffolded[0]["id"])
                self.assertNotEqual(refused.returncode, 0)
                self.assertIn("Cannot complete a scaffolded module.", refused.stderr)
                self.assertEqual(state_path.read_bytes(), retained_bytes)

            status = self.run_in_fixture(fixture, "status")
            self.assertEqual(status.returncode, 0, status.stderr)
            self.assertIn("1 completed", status.stdout)
            self.assertIn("Current: P02", status.stdout)

    def test_unknown_module_is_rejected(self):
        unknown = self.run_cli("start", "P99")
        self.assertNotEqual(unknown.returncode, 0)
        self.assertIn("Unknown module: P99", unknown.stderr)

    def test_failed_scaffold_start_preserves_current_module(self):
        scaffolded = [module for module in self.manifest["modules"] if module["status"] == "scaffolded"]
        if not scaffolded:
            self.skipTest("No scaffold remains to exercise failed-start recovery.")
        with tempfile.TemporaryDirectory() as temporary:
            fixture = self.build_fixture(temporary)
            started = self.run_in_fixture(fixture, "start", "P02")
            self.assertEqual(started.returncode, 0, started.stderr)
            refused = self.run_in_fixture(fixture, "start", scaffolded[0]["id"])
            self.assertEqual(refused.returncode, 2, refused.stderr)
            continued = self.run_in_fixture(fixture, "continue")
            self.assertEqual(continued.returncode, 0, continued.stderr)
            self.assertIn("P02 — Expose Floating-Point Roundoff", continued.stdout)
            state = json.loads((fixture / ".learning/progress.json").read_text(encoding="utf-8"))
            self.assertEqual(state["current"], "P02")


if __name__ == "__main__":
    unittest.main()
