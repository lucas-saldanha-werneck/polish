# Security policy

## Reporting a vulnerability

Please report security problems privately: open the **Security** tab of this repository and choose
**Report a vulnerability** (GitHub private vulnerability reporting). Please do not open a public issue
for a security problem. You will get an answer in the same thread.

## Supported versions

Only the latest release is supported. Fixes land in a new release; older versions are not patched.

## What this plugin accesses

- **What it is:** a skill, a set of instructions for Claude. It has no scripts and no hooks of its own.
- **What Claude may do when you use it:** read the files of the target you name, run the project's own tests, and, only after you pick changes, edit files and make commits on a new branch `polish/<date>`. It changes nothing before your pick.
- **Network and secrets:** the plugin adds none. A URL target is opened with Claude's own tools under your normal permissions.
