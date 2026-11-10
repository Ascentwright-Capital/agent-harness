# Standards for every repository

These apply to all code in Ascentwright-Capital, written by a person or by an AI agent. A repository
can add rules in its own `AGENTS.md` and `.agents/`; it cannot remove the hard rules.

## Hard rules

Breaking one is a bug, even if every check passes.

1. No secrets in a repository. Keep them in environment variables and keep `.env.example` current.
2. No personal data in logs, and no production data outside production.
3. Every change reaches `main` through a pull request. Nobody pushes to `main` directly or force
   pushes it.
4. Never merge your own pull request. Ken reviews and merges.

## Where things live

- Linear (workspace AP Venture, team `AP`) is the single source of truth for tasks, decisions,
  meeting notes, flows and specs. Write those as Linear documents, never as markdown in a repository.
- Every decision is the next `D-<number>` in the Decision log.
- A repository holds code, its tests, and the agent harness. A README says how to run it.

## Branches, commits and pull requests

- Start every change from a Linear issue, one issue per branch: `<type>/ap-<number>-<slug>`, where
  `<type>` is `feat`, `fix`, `refactor`, `docs`, `chore`, `style` or `test`.
- Commit and pull request titles start with `[Feat]`, `[Fix]`, `[Refactor]`, `[Docs]`, `[Chore]`,
  `[Style]` or `[Test]` and end with the issue ID, for example `[Feat] Add booking form (AP-12)`.
- Ken is the sole author. Do not add AI co-author or credit lines to commits or pull requests.
- Fill in the pull request template: what changed, why, how it was tested with every required check
  and its result, and each new dependency with its reason.
- Keep a pull request reviewable in one sitting, about 400 changed lines or fewer without tests and
  generated files. Squash merge.

## Rules for AI agents

- Read the repository's `AGENTS.md`, then `.agents/shared/`, before your first change. If it is empty, run `git submodule update --init`.
- A skill from the [skill stack](skills.md) is advice. These standards and the repository's `AGENTS.md` win where they differ.
- Stay inside the issue's scope. File other problems you find as new Linear issues.
- Work test first where the repository has tests: show the test that failed before and passes after.
- Run every check the repository's `AGENTS.md` lists before you open a pull request.
- Ask Ken before you touch a database schema, payments, authentication, personal data, production
  infrastructure, or DNS.
- When something cost you time, add it to the repository's pitfalls with its fix. When a rule can
  become a lint or a test, make it one and delete the prose.
