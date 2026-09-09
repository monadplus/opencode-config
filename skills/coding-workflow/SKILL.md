---
name: coding-workflow
description: Guide non-trivial design, implementation, refactoring, debugging, and testing. Use for multi-step coding work.
compatibility: opencode
---

# Coding Workflow

Keep the process proportional: learn local conventions first, choose the smallest behavior change, and use existing project tools. For complex work, plan three to five testable stages; use a temporary plan file only when it must survive across turns or workers, and remove it after completion.

Implement incrementally: understand adjacent code, add or update behavior tests when practical, make the minimum code pass, then refactor only while green. Prefer explicit data flow, simple names and types, composition, useful boundary errors, deterministic tests, and repository-provided build, formatter, lint, and test commands. Do not introduce a tool without strong justification.

After three failed attempts, stop and reassess using analogous local implementations. Never disable tests or use `--no-verify`. Before completion, run relevant verification or clearly state what remains unverified. Commit, push, PR/MR creation, and remote Git actions require explicit user approval immediately before each action.
