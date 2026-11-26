# Feature workflow

From a Linear issue to a pull request ready for review. Each step ends on its completion criterion;
do not start the next step before it holds. A repository can extend a step in its own
`.agents/workflows/`.

1. **Issue.** Read the Linear issue, its "Done when", and the decisions it cites. Done when you can
   state the done condition in one line.
2. **Open questions.** Ask about each choice that would change behavior, scope or money, with a
   recommendation. Record each answer as the next `D-<number>` in the Decision log. Done when no open
   question changes what you build.
3. **Branch.** Branch from an up-to-date `main` as `<type>/ap-<number>-<slug>`. Done when the
   repository's checks pass on the fresh branch.
4. **Test first, then build.** For web code, look up Modern Web Guidance before you write it
   ("Web code" in [`../standards.md`](../standards.md)). Done when every "Done when" item has a
   passing test.
5. **Review your own diff twice.** First for duplication and dead code, then for wrong results,
   missing checks, money, time and auth. Done when the second pass finds nothing new.
6. **Verify.** Run the change the way it ships, capture screenshots and a demo video, look at them,
   and publish them to the branch, as in [`verify.md`](verify.md). Done when the evidence shows every
   "Done when" item working.
7. **Pull request.** Run every check `AGENTS.md` lists, fill in the template with the evidence under
   "Verification", and link the issue. Done when CI passes, the "PR evidence" check included.
