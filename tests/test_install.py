import json
import os
import shutil
import subprocess
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INSTALL = os.path.join(ROOT, "install.sh")


def read(path):
    with open(path) as f:
        return f.read()


class InstallScript(unittest.TestCase):
    def setUp(self):
        self.home = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.home)
        self.claude = os.path.join(self.home, ".claude")
        os.makedirs(os.path.join(self.claude, "skills"))
        os.makedirs(os.path.join(self.claude, "hooks"))
        # Pre-create the clone targets so the script never touches the network.
        with open(os.path.join(ROOT, "external-skills.json")) as f:
            for skill in json.load(f):
                os.makedirs(os.path.join(self.home, "projects", "skills", skill["name"]))

    def install(self, answers=""):
        return subprocess.run(
            ["bash", INSTALL],
            input=answers,
            capture_output=True,
            text=True,
            env={**os.environ, "HOME": self.home},
        )

    def write(self, rel, content):
        path = os.path.join(self.claude, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            f.write(content)
        return path

    def test_fresh_install(self):
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(read(os.path.join(self.claude, "CLAUDE.md")), read(os.path.join(ROOT, "CLAUDE.md")))
        self.assertTrue(os.access(os.path.join(self.claude, "hooks", "noisy-filter.sh"), os.X_OK))
        self.assertTrue(os.path.isdir(os.path.join(self.claude, "skills", "graphify")))
        self.assertTrue(os.path.islink(os.path.join(self.claude, "skills", "stop-slop")))

    def test_declining_leaves_existing_files_untouched(self):
        claude_md = self.write("CLAUDE.md", "mine")
        settings = self.write("settings.json", "{}")
        hook = self.write("hooks/noisy-filter.sh", "my hook")
        skill = self.write("skills/graphify/SKILL.md", "my skill")
        os.symlink(self.home, os.path.join(self.claude, "skills", "glab"))

        result = self.install("n\n" * 10)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(read(claude_md), "mine")
        self.assertEqual(read(settings), "{}")
        self.assertEqual(read(hook), "my hook")
        self.assertEqual(read(skill), "my skill")
        self.assertEqual(os.readlink(os.path.join(self.claude, "skills", "glab")), self.home)
        self.assertEqual([f for f in os.listdir(self.claude) if ".bak." in f], [])

    def test_accepting_backs_up_the_old_file(self):
        settings = self.write("settings.json", '{"mine": true}')
        self.write("CLAUDE.md", read(os.path.join(ROOT, "CLAUDE.md")))

        result = self.install("y\n")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(read(settings), read(os.path.join(ROOT, "settings.json")))
        backups = [f for f in os.listdir(self.claude) if f.startswith("settings.json.bak.")]
        self.assertEqual(len(backups), 1)
        self.assertEqual(read(os.path.join(self.claude, backups[0])), '{"mine": true}')

    def test_broken_symlink_is_not_written_through(self):
        target = os.path.join(self.home, "dotfiles", "CLAUDE.md")
        link = os.path.join(self.claude, "CLAUDE.md")
        os.symlink(target, link)

        result = self.install()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(os.path.exists(target))
        self.assertTrue(os.path.islink(link))


if __name__ == "__main__":
    unittest.main()
