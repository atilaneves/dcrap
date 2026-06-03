# D CRAP Metric Evaluator

## Summary

Build a native D CLI that computes function-level CRAP scores for D projects:

```text
CRAP = CC^2 * (1 - coverage)^3 + CC
```

Use canonical risk threshold `CRAP > 30` for reporting, with explicit failure
gating only when the user asks for it. The first supported coverage format is
DMD/LDC `.lst` line coverage. The default coverage-generation path is DMD-first
and runs through the tool's normal single-command workflow.

Use DUB as the project/build/test runner. Add `unit-threaded` as the test
dependency and write the test suite with it.

Primary use case: audit D project quality, especially AI-generated code.
Important workflows include both whole-project baseline audits for existing
pre-dcrap projects and focused audits of functions touched by agentic coding.

## Current Status

Implemented:

- DUB package scaffold for the `dcrap` executable.
- `unit-threaded` test setup through `dub test`.
- Canonical CRAP score calculation and threshold failure checks.
- DMD/LDC `.lst` parsing for covered, uncovered, and non-executable lines.
- Coverage fraction and function-range coverage aggregation.
- Function score records containing source identity, range, complexity,
  coverage, and CRAP score.
- `libdparse`-based discovery of module-level functions and named nested
  functions, including line directive handling.
- Analyze-only row formatting for audit output experiments.
- Deterministic JSON serialization for analyze-only scored function rows.
- Analyze-only CLI threshold parsing and nonzero gate failure exit experiments.

In progress:

- Single-command source root and coverage wiring.
- First end-to-end implementation slice using `--no-run-tests` with existing
  `.lst` coverage and temporary complexity `1`.

Still pending:

- D-aware cyclomatic complexity extraction.
- Method, constructor, destructor, overload, and filtering golden tests.
- Default `dcrap` workflow that runs coverage and audits production modules.
- Built-in DMD-first coverage generation for the default workflow.
- Deterministic source and coverage path matching for production modules.
- Explicit failure gating with `--fail`; `--threshold` controls the CRAP score
  considered risky.
- Human-readable risky-function output by default, with deterministic JSON as
  an opt-in tool output.
- Production-focused default source filtering with explicit opt-ins for tests
  and generated code.
- Explicit coverage status so missing coverage is distinguishable from present
  zero-hit coverage.
- Full-project baseline audits by default, with changed-code audits planned as
  a first-class workflow after the core scoring pipeline is usable.

## Key Changes

- Scaffold a DUB package for a CLI executable, tentatively named `dcrap`.
- Configure DUB explicitly:
  - application target for the CLI
  - `unit-threaded` as a test dependency
  - `dub test` as the standard local verification command
- Use `libdparse` to parse D source files and collect named function-like
  ranges:
  - module functions
  - methods
  - constructors/destructors
  - named nested functions
- Do not create separate CRAP rows for lambdas, delegates, unittest blocks,
  contracts, or anonymous executable units in v1.
- Compute cyclomatic complexity with a practical syntax-level model using
  `libdparse`, not `dmd:frontend`, for v1:
  - base complexity `1`
  - count documented branch/control constructs such as conditionals, loops,
    switch labels, catches, ternaries, and boolean short-circuit operators
  - do not depend on compiler frontend internals or semantic analysis for the
    first production path
  - keep the implementation explainable enough to report future per-line
    complexity contributions
  - consider a `dmd:frontend` backend only if syntax-level analysis proves
    insufficient
- Parse DMD/LDC `.lst` files:
  - numeric count before `|` means executable covered line
  - `0000000|` means executable uncovered line
  - blank before `|` means non-executable line
- Map coverage to functions by source file plus function line range.
- Missing coverage for a parsed function is treated as `0%`.
- Distinguish missing coverage from present `.lst` coverage in score records
  and JSON output, for example with `coverageStatus: "missing"` versus
  `coverageStatus: "present"`.
- Show missing coverage clearly in human output as `Cov missing` rather than
  only `0.0%`.
- Include missing coverage in CRAP scoring as `0%`, and let it participate in
  explicit `--fail` gating.
- Discover production D source files under the configured source root, default
  `source`.
- Discover `.lst` coverage files under the configured coverage directory,
  default `.dcrap/coverage`.
- Match source files and coverage files by normalized project-relative path
  where possible.
- Ignore unmatched coverage files by default, but mention them in human output
  so users can diagnose stale or misdirected coverage artifacts.
- Prefer project-relative file paths in stable machine-readable output.
- Exclude dependencies and generated files by default.
- Exclude test code by default.
- Include `package.d` by default because it can contain production code in D.
- Exclude common non-production paths by default, including `.dub/`,
  `dub-packages/`, `test/`, `tests/`, `spec/`, `examples/`, and `generated/`.
- Exclude common test file names such as `*_test.d` by default.
- Provide explicit opt-ins and overrides such as `--include-tests`,
  `--include-generated`, and repeatable `--exclude <glob>`.
- CTFE coverage is not first-class in v1; document that CTFE-generated `.lst`
  files may be analyzed as normal input.
- Support two audit scopes:
  - full-project audit over production modules, used by default for pre-agent
    and pre-dcrap project baselines
  - changed-code audit for functions whose source ranges overlap changed lines,
    planned after the core source, coverage, and complexity pipeline works

## CLI Behavior

- Provide a single primary command:
  - `dcrap`
  - default source root: `source`
  - default coverage artifact directory: `.dcrap/coverage`
  - run `dub test` with DMD coverage settings by default
  - write coverage output to the controlled coverage directory using
    `DRT_COVOPT`
  - analyze generated `.lst` files after the coverage run
- Provide option overrides without requiring a subcommand for the common path:
  - `--source <path>` overrides the production source root
  - `--coverage <path>` overrides the coverage artifact directory or input
    location
  - `--no-run-tests` analyzes existing `.lst` coverage files without running
    `dub test`
  - `--json` emits deterministic JSON for tools and agents
  - `--all` includes every scored function in human output instead of only
    risky functions
  - `--include-tests` includes test paths and test-named files
  - `--include-generated` includes generated paths
  - `--exclude <glob>` excludes additional paths
  - `--changed` limits or emphasizes functions touched by local changes
  - `--since <ref>` limits or emphasizes functions changed since a git
    reference
  - `--threshold <score>` changes the CRAP score considered risky
  - `--fail` exits nonzero when any scored function exceeds the threshold
- Do not fail by default solely because high-CRAP functions are found. A
  successful report exits `0`; explicit failure gating is opt-in.
- Make DMD coverage generation the first production path. Detect unsupported
  compiler/runtime setups and report a clear error instead of trying to support
  every LDC/GDC coverage variant in v1.
- Implement the first usable slice as:
  - `dcrap --no-run-tests --coverage <path>`
  - `--source` defaults to `source`
  - discover source files
  - discover `.lst` coverage files
  - parse function ranges
  - assign temporary cyclomatic complexity `1`
  - aggregate coverage
  - compute CRAP
  - print human output
  - support `--json`
  - support explicit `--threshold` and `--fail`
- Add built-in DMD coverage generation for plain `dcrap` after the existing
  coverage analysis pipeline works.
- Replace temporary complexity with `libdparse`-based cyclomatic complexity
  after the pipeline is usable end to end.
- Output fields:
  - qualified function name
  - file path
  - line range
  - cyclomatic complexity
  - covered executable lines
  - total executable lines
  - coverage percent
  - coverage status
  - CRAP score
- Human output defaults to a triage report:
  - sort functions by descending CRAP score
  - show risky functions by default
  - show a compact summary with total functions, risky functions, and missing
    coverage counts
  - use `--all` to show every scored function
- JSON output is opt-in with `--json` and remains stable and complete
  regardless of human-output filtering.
- Exit nonzero for tool/runtime errors, and for CRAP scores only when explicit
  failure gating is enabled.
- Identify functions by qualified name plus file and line range.

## Test Plan

- Use `unit-threaded` for all unit and integration-style tests.
- Run tests through DUB.
- Add or change one behavior test at a time during TDD.
- Unit test CRAP formula edge cases:
  - `100%` coverage returns `CC`
  - `0%` coverage returns `CC^2 + CC`
  - threshold uses `> 30`, not `>= 30`
- Unit test `.lst` parser with covered, uncovered, and non-executable lines.
- Unit test function-range coverage aggregation.
- Unit test missing coverage maps to `0%`.
- Unit test analyze-only CLI threshold parsing:
  - default threshold is `30`
  - `--threshold` overrides the default
- Unit test analyze-only CLI gate decisions:
  - returns success when all CRAP scores are at or below threshold
  - returns failure when any CRAP score is greater than threshold
- Golden tests for representative D source:
  - plain functions
  - methods
  - constructors/destructors
  - named nested functions
  - overloads
  - excluded test/dependency/generated paths
- CLI integration tests should use temporary sandbox source and coverage
  artifacts. `.lst` files are build artifacts and must not be committed as
  canonical fixtures.
- Unit tests may use small inline `.lst` strings for parser grammar edge cases,
  but those examples are not substitutes for DMD compatibility validation.
- Standard verification includes one DMD coverage compatibility integration
  check that:
  - creates a tiny temporary D project
  - runs DMD coverage once, preferably with direct `dmd` invocation rather than
    `dub` to avoid repeated dependency resolution
  - parses the produced `.lst`
  - verifies key parser and matching properties
  - keeps generated `.lst` files out of git history
  - does not run per test case

## Assumptions

- v1 optimizes for practical DMD/LDC line coverage, not branch/path coverage.
- Test code is excluded by default because you chose product-code-focused
  scoring; later versions can add `--include-tests`.
- Dependencies and generated files are excluded by default, with explicit
  include/ignore flags.
- The evaluator may add dependencies as needed; local installed tools are not
  constraints.
