# Security policy

## Reporting a vulnerability

Please report security problems privately: open the **Security** tab of this repository and choose
**Report a vulnerability** (GitHub private vulnerability reporting). Please do not open a public issue
for a security problem. You will get an answer in the same thread.

## Supported versions

Only the latest release is supported. Fixes land in a new release; older versions are not patched.

## What this plugin accesses

- **What it is:** a skill, a set of instructions for Claude. It has no scripts and no hooks of its own.
- **Before your pick:** Claude reads the target's files, runs the app and its test suite to look at it and take screenshots (this runs the project's own code), and writes the report to its scratchpad (or shows it with an HTML report tool). It edits nothing in the target.
- **After your pick:** Claude edits files and commits on a new branch `polish/<date>` (or backs up each file first outside git). With uncommitted changes in the target, it asks before committing or stashing them.
- **Network and secrets:** the plugin adds none. A URL target is opened with Claude's own tools under your normal permissions.
