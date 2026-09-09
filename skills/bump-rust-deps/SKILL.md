---
name: bump-rust-deps
description: Update Rust dependencies one at a time with verification and explicit approval before commits or remote actions.
compatibility: opencode
---

# Bump Rust Dependencies

Require a clean tree and passing `cargo check` and `cargo clippy --all-targets --all-features -- -D warnings` baseline. Find direct outdated dependencies with `cargo outdated --root-deps-only --depth 1`, or use `cargo update --dry-run` when that optional tool is unavailable. Do not install tools automatically.

Process patch, then minor, then major updates. For each dependency, update the manifest, run `cargo update -p <crate>`, `cargo check --all-targets --all-features`, and clippy. Make only minimal compatibility fixes. After three unsuccessful attempts, revert that dependency's changes and report why.

Ask for explicit user approval immediately before every commit; do not commit by default. Ask again before any remote Git action. Finish with `cargo test --all-targets --all-features` and clippy. Report updated and skipped crates, checks, and any approved commits.
