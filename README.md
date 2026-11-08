# polish

A Claude Code skill that reviews an app, site, screen or codebase for simplicity, in the style of
Linear or Apple Notes, and changes nothing until you pick what to apply.

Ask a model to "clean up this page" and it starts editing at once: it cuts a label a test depends
on, or renames something another tool reads. This skill splits the job in two. First it lists every
change it would make and checks what each one would break. Then it stops and asks you. Only the
changes you pick get applied.

## What you get

Given a small notes page with a tagline, two lines of helper text and some dead code, `/polish
index.html` replied with this (copied from a real run, trimmed):

```
I found 9 possible changes. 7 are safe, 1 is an optional design change, and 1 changes behaviour,
so I need your OK on those two. Nothing breaks. I haven't changed `index.html`.

| id | change | check |
|---|---|---|
| D1 | Remove the tagline (line 5) | safe |
| D2 | Remove the helper text "Type your note below…" (line 7) | safe |
| D3 | Remove "(saved locally)" (line 9) | safe |
| D4 | Hide the "New note" label but keep it as the box's accessible name (`aria-label`) | safe, optional |
| I1 | Remove the unused `count` variable | safe |
| ...
| I5 | Clear the text box after Save | behaviour change, needs your OK |

Left alone: the `localStorage` key 'notes', because renaming it would lose saved notes.

What should I apply?
- All safe (D1–D3, I1–I4)
- Safe + D4 + I5
- Pick by id
```

It also wrote `polish-report.md` next to the page, with the full table (UX, DX and AX gain and risk
for each change, and how each check was done), a list of discarded ideas and a step-by-step plan.

## Install

```
/plugin marketplace add lucas-saldanha-werneck/polish
/plugin install polish@polish
```

## Use

```
/polish:polish [folder, file, URL or screen]
```

With no argument it reviews the current folder. You can also ask in plain words: "polish this",
"simplify this screen", "what would you cut here?".

## The rules it follows

1. One purpose per screen. If a screen's purpose doesn't fit in one short sentence, split it or cut
   it.
2. No taglines, helper text or secondary labels. If a screen needs them, fix the layout, the order
   or the main label instead.
3. Error messages, empty states, confirmations of destructive actions, units and accessibility
   names stay. A visible label that goes away moves to `aria-label`.
4. Each change must make UX (the user), DX (the developer) and AX (an agent that reads, tests and
   drives it) better, or at least not worse. A change that makes one of them worse is listed as
   discarded, with the reason.
5. Nothing breaks: same features, data, URLs, public API and passing tests.

## How it works

The skill is one file, `skills/polish/SKILL.md`. It tells Claude to:

1. Read the code, README and tests, and run the app and screenshot each screen if it can.
2. List every change across four layers (purpose, architecture, design, implementation), each with
   an id, location, before and after, UX/DX/AX gain and risk.
3. Check each change for breakage (grep for every use, run the test suite as a baseline, look for
   text other systems read, flag external contracts) and mark it safe, safe with an adjustment, or
   breaks. A change it could not check is marked "not checked", with the reason.
4. Write a plan of small, reversible steps, each naming the earlier steps it depends on (in a git
   repo, a `polish/<date>` branch with one commit per step).
5. Show the report, ask what to apply, and end the turn.
6. Apply only what you picked, running the tests after each step. A step that turns them red is
   undone, and the later steps that depend on it are skipped and reported as pending. At the end it
   runs the full test suite once more and compares it with the baseline.

## Optional requirements

None are needed. Without them the skill still works, with less evidence:

| If you have | It uses it to | Without it |
|---|---|---|
| A way to run and screenshot the app (Playwright, a browser tool, a run skill) | look at each screen before and after | reviews the code only and says so in the report |
| An HTML report skill such as `lavish` | show the report as a page | writes `polish-report.md` and puts the tables in chat |
| The `AskUserQuestion` tool | ask what to apply with buttons | asks in plain text |

## Test

```
sh tests/test_skill.sh          # checks the JSON files, the SKILL.md frontmatter and rules
sh tests/test_skill.sh --load   # also loads the plugin in a headless Claude Code session
```

The `--load` check reads the session's start-up event and passes only if it lists the skill
`polish:polish`. It does not trust what the model writes. It needs `claude` on your `PATH` and
uses one short model turn.

## Uninstall

```
/plugin uninstall polish@polish
/plugin marketplace remove polish
```

## Limits

- It is a prompt. How well it checks depends on the model and on the tools the session allows. In
  the run above, browser access was blocked, so it reviewed the code only and said so.
- Tested with Claude Code 2.1.319 in the terminal, on macOS. Not tested in the desktop app or on
  other systems.

## Credits

The review standard comes from two posts. Vox ([@Voxyz_ai](https://x.com/Voxyz_ai/status/2113254050170843418)) wrote the two AGENTS.md lines: cut taglines, helper text and secondary labels, and weigh UX, DX and AX together. Ram Maheshwari ([LinkedIn post](https://www.linkedin.com/posts/rammcodes_turns-out-the-secret-to-better-ai-generated-activity-7523265270833143808-rwbC)) added the "as perfect as Linear's website or Apple Notes" opening. The skill name and the review flow are mine.

MIT License. Copyright (c) 2026 Lucas Saldanha Werneck.

Built with Claude Code
