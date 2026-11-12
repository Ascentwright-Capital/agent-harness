# New repository

Ken creates repositories in the org. Then, in the first pull request:

1. Mount the harness:
   `git submodule add https://github.com/Ascentwright-Capital/agent-harness .agents/shared`
2. Copy [`../templates/AGENTS.md`](../templates/AGENTS.md) to the root and fill it in. Add a
   `CLAUDE.md` containing the single line `@AGENTS.md`.
3. Copy [`../templates/dependabot.yml`](../templates/dependabot.yml) to `.github/dependabot.yml`,
   so harness changes arrive as pull requests.
4. Copy [`../templates/claude-settings.json`](../templates/claude-settings.json) to
   `.claude/settings.json` (or merge its keys into the existing file), so every Claude Code
   session fetches the submodule and the repository turns on the core [skill stack](../skills.md).
   Run `sh .agents/shared/scripts/install-skills.sh` to install it.
5. Copy [`../templates/claude-hooks/block-ai-credit.sh`](../templates/claude-hooks/block-ai-credit.sh)
   to `.claude/hooks/block-ai-credit.sh`. The settings from step 4 run it before every shell and
   GitHub call, and it refuses a commit or pull request that credits an AI.
6. Add CI from the org's workflow templates (Actions → New workflow → Ascentwright Node CI). It
   checks out submodules and runs the harness check. List the same checks in `AGENTS.md`.
7. Add a README that says what the repository is and how to run it.
8. After the merge, Ken turns on: squash merge only, delete branches after merge, and (where the plan
   allows) a rule on `main` that requires a pull request and passing CI.
