#!/bin/sh
# Installs the skill plugins this repository enables in .claude/settings.json.
# Run from the repository root, once per clone and again after a harness bump.
set -eu

harness=.agents/shared
settings=.claude/settings.json

command -v claude >/dev/null || { echo "install-skills: the claude CLI is not on PATH" >&2; exit 1; }
[ -f "$harness/.claude-plugin/marketplace.json" ] || { echo "install-skills: $harness is empty; run git submodule update --init" >&2; exit 1; }
[ -f "$settings" ] || { echo "install-skills: $settings not found; run this from the repository root" >&2; exit 1; }

claude plugin marketplace add "./$harness" >/dev/null 2>&1 || claude plugin marketplace update ascentwright >/dev/null

grep -o '"[A-Za-z0-9._-]*@ascentwright"[[:space:]]*:[[:space:]]*true' "$settings" | cut -d'"' -f2 |
while read -r plugin; do
  claude plugin install "$plugin" --scope project </dev/null
  claude plugin update "$plugin" --scope project </dev/null >/dev/null 2>&1 || true
done
