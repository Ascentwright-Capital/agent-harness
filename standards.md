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
- Ken is the sole author. Never credit an AI in a commit, pull request, issue or comment: no
  `Co-Authored-By` an AI tool, no "Generated with", no `Claude-Session` line or Claude link, and no
  "Requested by" line. Commit as the person you work for, never as an AI. In Claude Code a hook refuses them
  ([`templates/claude-hooks/block-ai-credit.sh`](templates/claude-hooks/block-ai-credit.sh)), and
  the "AI credit" check fails any pull request that carries them, whoever wrote it. A pull request
  that brings in upstream commits takes the label `upstream-sync`, which skips the commit check.
- Fill in the pull request template: what changed, why, how it was tested with every required check
  and its result, and each new dependency with its reason.
- **Show it working.** A pull request is ready for review only when its "Verification" section shows
  the change working, captured from the built app or the pull request's preview, never a mockup:
  - Something people see (a page, a screen, a message, an email, a document): a screenshot of each
    changed screen in every language and size it ships in, and a demo video of each changed flow
    from its start to its result.
  - Nothing to see (CI, configuration, a library, a backend rule): `No visible surface:` with the
    reason, then the commands you ran and their output.

  Look at the evidence yourself before you post it: it is there to find problems, not to decorate
  the pull request. How: [`workflows/verify.md`](workflows/verify.md). The "PR evidence" check fails
  a pull request without it.
- Keep a pull request reviewable in one sitting, about 400 changed lines or fewer without tests and
  generated files. Squash merge.

## Rules for AI agents

- Read the repository's `AGENTS.md`, then `.agents/shared/`, before your first change. If it is empty, run `git submodule update --init`.
- A skill from the [skill stack](skills.md) is advice, except Modern Web Guidance for web code (below). These standards and the repository's `AGENTS.md` win where they differ.
- Stay inside the issue's scope. File other problems you find as new Linear issues.
- Work test first where the repository has tests: show the test that failed before and passes after.
- Run every check the repository's `AGENTS.md` lists before you open a pull request.
- Run your change and look at it before you open a pull request, then put the proof in it ("Show it
  working" above). Passing tests are not proof that a screen looks right.
- Ask Ken before you touch a database schema, payments, authentication, personal data, production
  infrastructure, or DNS.
- When something cost you time, add it to the repository's pitfalls with its fix. When a rule can
  become a lint or a test, make it one and delete the prose.

## Web code

Before you write or change HTML, CSS or client-side JavaScript (pages, components, layout,
animation, forms, accessibility, performance, or security in the browser), look up the current
practice in Google Chrome's [Modern Web Guidance](https://developer.chrome.com/docs/modern-web-guidance)
and build to it. Web platform features change faster than any model's training, so this is a rule,
not advice. It does not apply to backend, infrastructure, scripts or tooling.

1. Search with a short query for one capability, for example `"light dismiss dialog"` or
   `"responsive data table"`. Split a task with several features into several searches:
   `npx -y modern-web-guidance@latest search "<query>"`
2. Retrieve the guides that match, plus the discipline guide that applies (`html`, `css`, `js`,
   `forms`, `accessibility`, `performance`, `security`), comma separated:
   `npx -y modern-web-guidance@latest retrieve "<id>,<id>"`
3. Build to the guides, fallbacks included, and check your code against them before you open the
   pull request.
4. Under "How it was tested", list each guide ID you applied and what it changed, or the topics you
   searched when none applied.

The `modern-web-guidance` plugin in the [skill stack](skills.md) runs these steps for you; without it,
run the commands. Browser support is Baseline Widely available, with each guide's fallbacks for
anything newer, unless the repository's `AGENTS.md` sets another target. Run `legacy-scan` only when
the issue asks to modernize a whole codebase.
