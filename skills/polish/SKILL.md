---
name: polish
description: 'Simplicity review of an app, site, screen or codebase in the style of Linear or Apple Notes (simple purpose, simple architecture, simple design, simple implementation). Lists every change it would make (cut taglines, helper text and secondary labels, fix the layout that depends on them, simplify code), each with its gain for UX, DX and AX, checks whether each change would break anything, and writes an implementation plan. Changes nothing until the user picks. Use when the user says "/polish", "polish this", "make it as clean as Linear", "simplify this screen", "what would you cut here?" or asks for a simplicity review.'
argument-hint: "[folder, file, URL or screen]"
version: "0.1.7"
metadata:
  author: Lucas Saldanha Werneck <lucas@2olhares.com>
  tags: [review, simplicity, ux]
---

# /polish: point, check, plan. Change only after the user picks.

## Purpose

Find what to cut or simplify in an app, site, screen or codebase, prove each change is safe, and hand the user a plan; nothing is changed until the user picks.

## Instructions

1. Understand the target and change nothing (read the code, run it, take screenshots).
2. List every change across purpose, architecture, design and implementation, each with its UX / DX / AX gain and risk.
3. Check each change for breakage and mark it safe, safe with adjustment, or breaks.
4. Write the implementation plan and the report, ask what to apply, and stop. Implement only what the user picks.

## The standard

> As polished as Linear's website or Apple Notes. Simple purpose, simple architecture, simple design, simple implementation.
>
> 1. **One purpose per screen.** If you can't say what a screen is for in one short sentence, split it or cut it.
> 2. **No taglines, helper text or secondary labels.** If a screen needs them to make sense, fix the layout, the order or the wording of the primary label instead.
> 3. **Keep what is not decoration.** Error messages, empty states, confirmations of destructive actions, units, and accessibility names (`aria-label`, `alt`) stay. Cut them only if the visible design makes them redundant, and move the name to `aria-label` instead of deleting it.
> 4. **Every change must make UX, DX and AX better at once**, or at least not worse in any of the three. UX = the person using it. DX = the developer reading and changing the code. AX = an agent reading, testing and driving it (stable names, clear structure, predictable URLs and selectors, one source of truth).
> 5. **Nothing breaks.** Same features, same data, same URLs, same public API, same tests passing. Simpler must not mean "does less" unless the user approves the cut.

## Flow

### 1. Understand the target (change nothing)
- Target = the argument; with no argument, the current folder.
- Read the code, the README / CLAUDE.md and the tests. If it is an app or a site, **run it and look at it** (with whatever you have: a run skill, Playwright, a browser tool) and take a screenshot of each screen. Don't audit from the code alone. If you can't run it, say so in the report.
- Write the purpose of the product and of each screen in one sentence. If you can't, that is finding number 1.

### 2. List EVERY change
Sweep these 4 layers, in this order:
1. **Purpose**: screens, features or steps that don't serve the purpose.
2. **Architecture**: files, layers, dependencies, configs, duplicated state; two sources of the same truth.
3. **Design**: taglines, helper text, secondary labels, decorative icons, extra borders/shadows/colors, uneven spacing, weak hierarchy, layout that needs explaining.
4. **Implementation**: dead code, abstractions with a single use, confusing names, flags and props nobody uses, selectors that are fragile for agents.

Each change is one line with: **id** (P1, A1, D1, I1...), **where** (`file:line` or screen), **what changes** (before -> after), **UX / DX / AX gain** (one word each, or "=" if neutral), **risk** (low / medium / high).

A change that makes UX, DX or AX worse does not go in the main list. It goes under "discarded" with the reason.

### 3. Check whether it breaks (before calling it safe)
For EACH change, really check and note how you checked:
- **Who uses it:** `grep` every use of the text, component, function, route or class (including tests, e2e, Playwright selectors, docs, other skills or agents that read the screen).
- **Tests:** run the current suite and keep the result as the baseline. Note which tests touch the change.
- **Text another system reads:** a label used as a test selector, a translation key, email text, SEO (`title`, `meta`), screen readers.
- **External contract:** URL, API, field name, file format, environment variable. Changing one = high risk.
- Mark each change: **safe** (checked, nothing depends on it) / **safe with adjustment** (name the adjustment, e.g. "update the selector in test X") / **breaks** (say what; it goes in only if the user accepts).

Didn't check? Write "not checked: <why>". Never mark a change safe by deduction.

### 4. Implementation plan
- Order: low-risk safe changes first, then safe-with-adjustment, then anything that touches architecture.
- Small, reversible steps. Each step says: which changes (ids), depends on: which earlier steps it needs ("none" if it stands alone), how to test afterwards (command, before/after screenshot), how to undo (its own commit or a backup).
- In a git repo: a new branch `polish/<date>`, one commit per step, so undoing a step is undoing its own commit.

### 5. Show and stop
- Write the report: purpose in one sentence, table of changes by layer, before screenshots, the check column, the plan, the discarded list. If an HTML report tool is available (for example the `lavish` skill), use it; otherwise write a Markdown file `polish-report.md` in the scratchpad (never in the target: nothing in it changes before the user picks) and show the tables in chat.
- In chat: a short summary (how many changes, how many safe / safe with adjustment / breaks, where the report is).
- Ask what to apply: "all safe", "safe + safe with adjustment", or "I'll pick by id". Use the `AskUserQuestion` tool if it is available; otherwise ask in plain text. For a big visual change, describe 2 or 3 options in text first.
- **End the turn. Implement nothing in this step.**

### 6. Implement (only what the user picked)
- Before the first change, run `git status` in the target. Uncommitted changes there are the user's work: ask whether to commit or stash them first (`git stash push -m "before polish"`), and do not start until the tree is clean. Not a git repo: back up each file before you touch it.
- Follow the plan step by step. After each step: run the tests, compare with the baseline, screenshot the screen you touched.
- If a test turns red or the screen got worse: undo the step and note it. Undo only that step: revert its own commit, or restore the files it touched from their backup; never `git checkout -- .`, `git reset --hard` or `git clean`, which also throw away work that is not the step's. Then skip every later step that depends on it, mark each one pending with the reason, and go on with the steps that don't.
- When the steps are done, run the full test suite once more and compare it with the baseline. Anything worse than the baseline is not done: undo the step that caused it or report it as broken.
- At the end: before/after screenshots, test results (real output), what was done, and what is still pending with the reason (or "nothing pending").

## Prerequisites

- Read access to the target (code, a running app or a URL). Screenshots and a test suite help but are optional.
- A git repo is needed only for the branch-per-step plan.

## Limitations

- It changes nothing until the user picks the changes to apply.
- A change it could not check is marked "not checked" with the reason; it is never called safe by deduction.
- A change that makes UX, DX or AX worse goes under "discarded", not in the main list.

## Troubleshooting

- No test suite or the app cannot be run: write "not checked: <why>" for each affected change and say so in the report.
- Error from a baseline test run: record it as the baseline before changing anything, so later failures can be compared.

## Examples

- User: "/polish" in an app folder. Claude reads and runs the app, lists every change with its gain and risk, checks each one, writes the plan and asks what to apply.
- User: "/polish https://example.com/pricing". Claude reviews that page the same way and changes nothing.
- User: "simplify this screen", then "all safe". Claude implements only the changes marked safe, step by step, running the tests after each.
