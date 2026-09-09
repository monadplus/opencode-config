---
description: Execute the approved plan with dependency-aware parallel workers and integrated local validation.
---
Follow the current conversation plan. Extra context or constraints: $ARGUMENTS

Build a dependency DAG. Group work that shares files, APIs, or strong dependencies into one owning workstream; dispatch independent ready work in parallel with the narrowest suitable worker. Use `rust-design` only for unresolved Rust design. Before implementation, use targeted design or review work only where risk, ambiguity, or independent expertise warrants it.

After implementation, run one integrated local fast preflight using documented formatters, checks, linters, and targeted tests. Inspect status and diff. Do not run routine per-workstream reviews, verification, or commits.

Run a final integrated local review of the candidate diff for bugs, regressions, missing tests, quality, plan conformance, and scope drift. Deduplicate and resolve the resulting findings in one owning fix batch, then repeat the fast preflight and local final review as needed.

Before each commit, fetch, push, PR/MR creation, CI query, or other remote Git/hosting action, request the user's explicit approval immediately before that individual action. After an approved commit/push, capture the resulting commit SHA and merge base; review that immutable committed diff and watch CI in parallel. Findings from that immutable review and CI failures enter the same bounded loop: fix -> fast preflight -> local final review -> obtain fresh approval for each commit or remote action -> commit/push -> fresh immutable review and CI. Retain each exact failed CI command. Never treat a prior review or CI result as current after a new SHA; do not re-review transient CI retries for an unchanged SHA. Cap fix-and-repush iterations at three; then report outstanding findings and tradeoffs.

If any remote action is declined, still complete the local final review and report CI as unresolved rather than successful. Complete only with a clean local review plus successful CI for the latest committed SHA, or explicit accepted tradeoffs. Report validation, approvals requested or received, unresolved CI, and residual risks.
