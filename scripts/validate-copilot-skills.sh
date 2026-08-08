#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd -- "$script_dir/.." && pwd -P)"
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/validate-copilot-skills.XXXXXX")"

cleanup() {
  rm -rf -- "$temporary_root"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

assert_skills() {
  local expected_source="$1"
  local skills_json="$2"

  node - "$expected_source" "$skills_json" <<'NODE'
const fs = require("fs");

const [expectedSource, skillsPath] = process.argv.slice(2);
const expectedNames = [
  "plan-archive",
  "plan-create",
  "plan-critique",
  "plan-execute",
];
const skills = JSON.parse(fs.readFileSync(skillsPath, "utf8"));
const planSkills = skills.filter((skill) => skill.name.startsWith("plan-"));
const actualNames = planSkills.map((skill) => skill.name).sort();

if (JSON.stringify(actualNames) !== JSON.stringify(expectedNames)) {
  console.error(`Expected plan skills: ${expectedNames.join(", ")}`);
  console.error(`Actual plan skills: ${actualNames.join(", ")}`);
  process.exit(1);
}

const invalidSkills = planSkills.filter(
  (skill) => skill.source !== expectedSource || skill.enabled !== true,
);

if (invalidSkills.length > 0) {
  console.error(
    `Expected enabled ${expectedSource} skills: ${JSON.stringify(invalidSkills)}`,
  );
  process.exit(1);
}
NODE
}

configure_copilot_home() {
  local home_directory="$1"

  export HOME="$home_directory"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_DATA_HOME="$HOME/.local/share"
  mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"
}

find "$repository_root/skills" "$repository_root/.gemini/skills" "$repository_root/.github/skills" \
  -type f -name '*.md' -print0 |
  xargs -0 awk '
    length > 120 {
      printf "%s:%d:%d\n", FILENAME, FNR, length
      failed = 1
    }
    END {
      exit failed
    }
  '

plugin_home="$temporary_root/plugin-home"
plugin_project="$temporary_root/plugin-project"
configure_copilot_home "$plugin_home"
mkdir -p "$plugin_project"

copilot plugin marketplace add "$repository_root"
copilot plugin install plan@serbanghita

(
  cd "$plugin_project"
  copilot skill list --json > "$temporary_root/plugin-skills.json"
)
assert_skills plugin "$temporary_root/plugin-skills.json"

manual_home="$temporary_root/manual-home"
manual_project="$temporary_root/manual-project"
configure_copilot_home "$manual_home"
mkdir -p "$manual_project/.github/skills"
cp -R "$repository_root/.github/skills/." "$manual_project/.github/skills/"
cp "$repository_root/working-agreement.md" "$manual_project/"

(
  cd "$manual_project"
  copilot skill list --json > "$temporary_root/manual-skills.json"
)
assert_skills project "$temporary_root/manual-skills.json"
