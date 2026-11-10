# <Repository name>

<One paragraph: what this repository is, who uses it, where it runs.>

If `.agents/shared` is empty, run `git submodule update --init` first.

Read [`.agents/shared/standards.md`](.agents/shared/standards.md) before your first change. It holds
the rules every Ascentwright repository shares. This file and `.agents/` add the rules for this
repository only.

## Run it

```sh
<install>
<run locally>
```

## Before a pull request

Run each of these and report the results in the pull request:

- `<typecheck>`
- `<lint>`
- `<test>`
- `<build>`

## Deploy

<How `main` reaches production, and how to roll back.>

## Repository rules

<Only rules specific to this repository. Link to a file in `.agents/` for anything longer.>
