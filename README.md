# agent-harness

The rules, workflows and skills that every Ascentwright-Capital repository shares, for people and
for AI agents. Each repository keeps a synced copy in `.agents/shared/`, so an agent that has cloned
only that repository still has everything it needs.

| Path | What it holds |
|---|---|
| [`shared/`](shared/README.md) | What gets copied into every repo: standards, workflows, skills. |
| [`templates/AGENTS.md`](templates/AGENTS.md) | The starting `AGENTS.md` for a new repository. |
| [`scripts/sync.sh`](scripts/sync.sh) | Copies `shared/` into a repository and pins the version. |
| [`repos.txt`](repos.txt) | The repositories that receive the shared files. Keep it in step with the matrix in `.github/workflows/sync.yml`. |
| [`.github/workflows/sync.yml`](.github/workflows/sync.yml) | Opens a sync pull request in each repository when `shared/` changes on `main`. |

## Using it in a repository

```sh
# from the root of the repository, with agent-harness cloned next to it
../agent-harness/scripts/sync.sh .
git add .agents/shared && git commit -m "[Chore] Sync the agent harness (AP-n)"
```

The repository's CI calls the `harness-check` workflow in `Ascentwright-Capital/.github`, which fails
when `.agents/shared/` no longer matches the pinned version.

## Changing a shared rule

Change it here, in a pull request, then sync each repository. A rule that only one repository needs
belongs in that repository's own `.agents/`, not here.
