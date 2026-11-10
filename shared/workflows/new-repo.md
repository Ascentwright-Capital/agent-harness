# New repository

Ken creates repositories in the org. Then, in the first pull request:

1. Copy [`templates/AGENTS.md`](https://github.com/Ascentwright-Capital/agent-harness/blob/main/templates/AGENTS.md)
   to the root and fill it in. Add `CLAUDE.md` containing the single line `@AGENTS.md`.
2. Run `agent-harness/scripts/sync.sh` to add `.agents/shared/`.
3. Add CI from the org's workflow templates (Actions → New workflow → Ascentwright Node CI), and list
   the same checks in `AGENTS.md`.
4. Add a README that says what the repository is and how to run it.
5. After the merge, Ken turns on: squash merge only, delete branches after merge, and (where the plan
   allows) a rule on `main` that requires a pull request and passing CI.
