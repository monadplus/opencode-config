---
name: rebase
description: Rebase safely with conflict resolution, validation, and final comparison against the base branch.
compatibility: opencode
---

# Safe Rebase

Require a feature branch and a clean worktree. If work must be preserved, ask for explicit approval before creating a safeguard commit. Resolve the base from existing local refs; before fetching or otherwise contacting a remote, obtain explicit user approval immediately before that remote action.

Capture `HEAD`, merge base, commit list, and diffstat before rebasing. If the optional `weave` CLI is installed, it may be previewed or configured locally after approval for the local Git configuration change; never install it automatically. Rebase with `git rebase <base>`.

For each conflict, inspect stages 1, 2, and 3 and the related commits; resolve intent and invariants rather than merely removing markers. Stage each resolved file, run focused validation, and continue. Prefer documented format and full validation commands, otherwise use applicable local tools.

Finally inspect cleanliness, `git range-diff` from old to new series, and the final base-branch diff. Never use `--no-verify`, force push, or drop commits without explicit approval. Any remote Git action after the rebase also requires immediate explicit user approval.
