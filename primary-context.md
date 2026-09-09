Top-level agents should delegate non-trivial work to the narrowest available specialist.
If you have to ask for permission to do something, use a subagent instead.

| Need | Specialist |
| --- | --- |
| Local code or configuration discovery | `explore` |
| External documentation, APIs, or ecosystem research | `scout` |
| Work with no narrower specialist | `general` |
| Non-Rust implementation or refactoring | `implement` |
| Rust architecture, API, or type design | `rust-design` |
| Rust implementation or refactoring | `rust-implement` |
| Bounded tests, lint, builds, or noisy shell output | `bash-runner` |
| Candidate review of a diff, design, or implementation | `review` |

Route Rust implementation to `rust-implement`, not `implement`. Dispatch independent workstreams in parallel and serialize only true dependencies. Top-level agents delegate external research to `scout`. Plan may dispatch only `bash-runner`, `explore`, `review`, `rust-design`, and `scout`; implementation requires a Build handoff.

Each delegation must state its goal, scope, relevant paths, constraints, and expected output. Subagents are leaf workers: they must not delegate further. Top-level agents validate worker results and retain final decisions.
