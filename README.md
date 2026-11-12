# agent-harness

The rules, workflows and templates that every Ascentwright-Capital repository shares, for people and
for AI agents. Each repository mounts this repository as a git submodule at `.agents/shared`.

| Path | Read it when |
|---|---|
| [`standards.md`](standards.md) | Before your first change in any Ascentwright repository. |
| [`workflows/feature.md`](workflows/feature.md) | You take a Linear issue to a pull request. |
| [`workflows/new-repo.md`](workflows/new-repo.md) | You set up a new repository, or add the harness to one. |
| [`skills.md`](skills.md) | You want to know which skills a repository loads, or change them. |
| [`templates/`](templates/) | You add the harness to a repository: `AGENTS.md`, Dependabot, Claude Code settings and the hook that blocks AI credit. |

The repository's own `AGENTS.md` and `.agents/` add to these rules and win where the two differ.

## If `.agents/shared` is empty

The submodule was not fetched. From the repository root:

```sh
git submodule update --init
```

## Changing a shared rule

Change it here, in a pull request. Dependabot then opens a pull request in each repository that bumps
the submodule; merging it is how a repository takes the new rules. A rule that only one repository
needs belongs in that repository's own `.agents/`, not here.
