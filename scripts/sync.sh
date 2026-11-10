#!/usr/bin/env bash
# Copy shared/ into <repo>/.agents/shared and pin the agent-harness commit it came from.
# Usage: scripts/sync.sh <path-to-repo>
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
target="${1:?usage: sync.sh <path-to-repo>}"
dest="$target/.agents/shared"

rm -rf "$dest"
mkdir -p "$dest"
cp -R "$here/shared/." "$dest/"
git -C "$here" rev-parse HEAD > "$dest/VERSION"

echo "Synced agent-harness $(cat "$dest/VERSION") into $dest"
