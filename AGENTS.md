# agent-harness

This repository is the source of the shared agent harness. Read [README.md](README.md) first.

- Edit `shared/` here; never edit a synced copy in a product repository.
- A rule belongs in `shared/` only when every repository needs it.
- Before a pull request, check that `scripts/sync.sh` still works: `scripts/sync.sh "$(mktemp -d)"`.
- Conventions are in [`shared/standards.md`](shared/standards.md).
