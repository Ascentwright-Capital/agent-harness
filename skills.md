# Skill stack

The skills every Ascentwright repository can load in Claude Code. This repository is a Claude Code
plugin marketplace named `ascentwright`: [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json)
lists each skill set as a plugin and pins it to one reviewed commit of its upstream repository.
Nothing is copied here.

[standards.md](standards.md) and the repository's `AGENTS.md` win over any skill. Where a skill says
to proceed without asking, the "Ask Ken" rule still applies. Where a skill opens, merges or
force pushes a pull request, the hard rules still apply.

## Core plugins

The settings template turns these on in every repository.

| Plugin | From | Use it for |
|---|---|---|
| `pstack` | Lauren Tan's pstack, [Claude Code port](https://github.com/michael-denyer/pstack-claude) | Planning and review: `/pstack:architect`, `/pstack:how`, `/pstack:why`, `/pstack:interrogate`, `/pstack:tdd`, `/pstack:unslop`. |
| `mattpocock-skills` | [mattpocock/skills](https://github.com/mattpocock/skills) | Issue to code: `/mattpocock-skills:grill-me`, `to-spec`, `to-tickets`, `tdd`, `diagnosing-bugs`, `code-review`. |
| `emilkowalski-skills` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | Interface work: `/emilkowalski-skills:emil-design-eng`, `animate`, `review-animations`, `break-ui`. |

`pstack` runs a hook at session start. It tells the agent to route larger tasks through
`/pstack:poteto-mode`.

## Opt-in plugins

Listed in the marketplace and off by default. Turn one on in the repository that needs it.

| Plugin | From | Use it for |
|---|---|---|
| `superpowers` | [obra/superpowers](https://github.com/obra/superpowers) | Brainstorming, written plans, systematic debugging. Runs its own hook at session start, so do not pair it with `pstack` without a reason. |
| `impeccable` | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | Frontend design polish, audit and critique. Runs hooks after edits. |
| `frontend-design`, `webapp-testing`, `skill-creator` | [anthropics/skills](https://github.com/anthropics/skills) | Building an interface, testing a web app with Playwright, writing a skill. |
| `web-design-guidelines`, `react-best-practices` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | Reviewing UI code; React and Next.js performance. |
| `differential-review`, `insecure-defaults`, `supply-chain-risk-auditor` | [trailofbits/skills](https://github.com/trailofbits/skills) | Security review of a change, of configuration, and of dependencies. |

To turn one on, add `"<plugin>@ascentwright": true` under `enabledPlugins` in the repository's
`.claude/settings.json`, then run the install script.

## Install

Each person runs this once per clone, from the repository root, and again after a pull request that
bumps `.agents/shared`:

```sh
sh .agents/shared/scripts/install-skills.sh
```

It registers `.agents/shared` as the marketplace and installs every plugin the repository enables.
Skills appear in the next Claude Code session as `/<plugin>:<skill>`.

A Claude Code cloud session does not load plugins that a repository's settings turn on. To give
cloud sessions the stack, an owner of the Claude organization adds the same `extraKnownMarketplaces`
and `enabledPlugins` keys to the organization's managed settings, with the marketplace source
`{ "source": "github", "repo": "Ascentwright-Capital/agent-harness" }`.

## Change the stack

A plugin can run hooks and scripts on every machine that installs it, so every change is a pull
request here.

- **Bump a pin.** Read the upstream diff between the old and the new commit, then change `sha`.
- **Add a plugin.** Add an entry with a full 40-character `sha`. Make it `"defaultEnabled": false`
  unless every repository needs it, and add it to the table above.
- **Check it.** Run `claude plugin validate .`, then install the changed plugin from a local copy of
  the marketplace and confirm `claude plugin details <plugin>` lists its skills.

Not included: [garrytan/gstack](https://github.com/garrytan/gstack), which ships its own installer
and browser binary and is not a plugin.
