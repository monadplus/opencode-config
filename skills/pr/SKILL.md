---
name: pr
description: Prepare and open a GitHub pull request with gh using minimal reviewer-focused text and explicit remote approval.
compatibility: opencode
---

# Open GitHub Pull Request

Require a committed feature branch, `gh` installed and authenticated, and a clean tree. Inspect branch, status, commits, diffstat, and the resolved base branch before drafting a concise reviewer-focused title and an empty or 1-3 bullet description. Do not create or modify commits unless separately approved.

Before *every* remote Git or GitHub operation—including fetching metadata, pushing, or `gh pr create`—obtain explicit user approval immediately before the action. Confirm again before the push and again before PR creation; prior general approval is not sufficient. Never force push or use `--no-verify` unless explicitly requested.

For Rust repositories, prefer documented validation; otherwise run `cargo fmt`, `cargo clippy --workspace --all-targets --all-features -- -D warnings`, and `cargo test`. Stop on failures. On success, report PR URL, base and head branches, description rationale, validation, and follow-ups.
