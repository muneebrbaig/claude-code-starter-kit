import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOOK = os.path.join(ROOT, "hooks", "pretooluse-bash-filter.sh")
FILTER = os.path.join(ROOT, "hooks", "noisy-filter.sh")


def run_hook(command, tool="Bash"):
    payload = json.dumps({"tool_name": tool, "tool_input": {"command": command}})
    return subprocess.run(
        [sys.executable, HOOK], input=payload, capture_output=True, text=True
    )


def rewritten(command):
    out = run_hook(command).stdout
    if not out:
        return None
    return json.loads(out)["hookSpecificOutput"]["updatedInput"]["command"]


class BashFilterHook(unittest.TestCase):
    def test_noisy_commands_are_wrapped(self):
        for cmd in [
            "npm install",
            "sudo apt-get install foo",
            "cd app && cargo build --release",
            "make",
            "docker build -t x .",
            "mvn test",
        ]:
            with self.subTest(cmd=cmd):
                wrapped = rewritten(cmd)
                self.assertIsNotNone(wrapped)
                self.assertIn("noisy-filter.sh", wrapped)

    def test_other_commands_pass_through(self):
        for cmd in [
            "git status",
            "ls -la",
            "git commit -m 'make it work'",
            "grep make Makefile",
            "echo npm install",
        ]:
            with self.subTest(cmd=cmd):
                self.assertIsNone(rewritten(cmd))

    def test_non_bash_tool_is_ignored(self):
        self.assertEqual(run_hook("npm install", tool="Read").stdout, "")


class NoisyFilter(unittest.TestCase):
    def run_filter(self, text):
        return subprocess.run(
            ["bash", FILTER], input=text, capture_output=True, text=True
        ).stdout

    def test_keeps_error_and_warning_lines(self):
        lines = ["noise %d" % i for i in range(50)]
        lines[3] = "ERROR: boom"
        lines[7] = "warning: deprecated"
        out = self.run_filter("\n".join(lines) + "\n")
        self.assertIn("ERROR: boom", out)
        self.assertIn("warning: deprecated", out)
        self.assertNotIn("noise 10\n", out.split("---")[0])
        self.assertIn("30 earlier lines filtered", out)

    def test_empty_input_prints_nothing(self):
        self.assertEqual(self.run_filter(""), "")


class SettingsHookCommand(unittest.TestCase):
    """Runs the command from settings.json with only one Python name on PATH."""

    def run_with_python_named(self, name):
        with open(os.path.join(ROOT, "settings.json")) as f:
            command = json.load(f)["hooks"]["PreToolUse"][0]["hooks"][0]["command"]
        with tempfile.TemporaryDirectory() as home:
            hooks = os.path.join(home, ".claude", "hooks")
            shutil.copytree(os.path.join(ROOT, "hooks"), hooks)
            bindir = os.path.join(home, "bin")
            os.mkdir(bindir)
            os.symlink(sys.executable, os.path.join(bindir, name))
            payload = json.dumps(
                {"tool_name": "Bash", "tool_input": {"command": "npm install"}}
            )
            return subprocess.run(
                ["/bin/sh", "-c", command],
                input=payload,
                capture_output=True,
                text=True,
                env={"HOME": home, "PATH": bindir},
            )

    def test_works_with_python3_only(self):
        self.assertIn("noisy-filter.sh", self.run_with_python_named("python3").stdout)

    def test_works_with_python_only(self):
        self.assertIn("noisy-filter.sh", self.run_with_python_named("python").stdout)

    def test_no_python_exits_nonzero(self):
        self.assertNotEqual(self.run_with_python_named("perl").returncode, 0)


if __name__ == "__main__":
    unittest.main()
