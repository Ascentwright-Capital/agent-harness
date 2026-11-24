---
name: be-ambitious
description: "Make a task deeper, not bigger: name the field, say what a top professional would do that wasn't asked for, the rawest material, the specific methods, tools and skills, and the external check with its pass criterion, then rewrite the prompt to ask for exactly that. Stops after the rewrite. Use for /be-ambitious, 'be ambitious', or 'make this deeper'."
---

# Be ambitious

Adapted from a prompt shared by Felix Rieseberg (Anthropic).

I want a deeper version of this task, not a bigger one. Before rewriting it: (1) say what a top
professional in this field would do here that I'm not asking for; (2) name the rawest material they
would start from instead of what has already been digested for me; (3) name the specific methods and
tools they would use; (4) say what, other than you or me, would show the result is right. Then
rewrite my prompt to ask for exactly that.

## Input

The task is whatever follows the command (`/ascentwright:be-ambitious`). If nothing follows, use the
user's most recent request in this conversation. If there is none, ask for the task in one line and
stop.

## Deeper, not bigger

Keep the user's goal and scope. Depth means a higher standard for the same outcome: better sources,
sharper methods, real verification. Do not add deliverables, features, or side quests. If a
suggestion would make the job larger rather than better, drop it.

## Steps

Name the field first (e.g. "investigative journalism", "SRE incident response", "clinical
pharmacology"), then answer the four questions for that field. Be concrete: name the actual thing,
not the category.

1. **What a top professional would do that wasn't asked for.** The two or three moves that separate
   expert work from competent work here, such as stating the decision the work serves, checking base
   rates, reproducing before fixing, or writing the counter-argument.
2. **The rawest material.** The primary sources they would start from instead of summaries: the
   dataset, not the chart; the filing, not the article; the logs and the code, not the bug report;
   the paper's methods section, not the abstract. Say where it lives if you know.
3. **Specific methods, tools, and skills.** Name the techniques, instruments, libraries, commands,
   or frameworks that fit this task and explain why. Check the current skill list and select the
   smallest set of skills that materially improve the work within scope. For each, give its exact
   listed name, the step it supports, and what to use it for. If none fit, omit skill instructions.
4. **What, other than the user or the model, would show it is right.** An external check: a test
   suite or benchmark, a reproduction, ground-truth data, a known answer to compare against, a
   measurement, a domain expert or reviewer, a real user's behavior. Say what result would count as
   a pass and what would count as a failure.

If you don't know something in the field well enough to answer, say so rather than inventing a
source or tool.

## Rewrite

Then write the rewritten prompt in a single fenced block the user can copy. It should ask for
exactly what the four answers describe: start from the raw material, use the named methods, and end
with the external check and its pass criterion. In the prompt, tell the executing agent to load and
follow each selected skill by name at the step it supports. If a named skill is unavailable to that
agent, have it use a relevant available equivalent or proceed with the specified method. Keep the
prompt in the user's voice and as short as the task allows.

Stop after the rewrite. Offer in one line to run it now; don't start the task unless the user says
so.
