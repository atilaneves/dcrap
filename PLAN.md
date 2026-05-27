# D CRAP Metric Evaluator

## Summary

Build a native D CLI that computes function-level CRAP scores for D projects:

```text
CRAP = CC^2 * (1 - coverage)^3 + CC
```

Use canonical failure threshold `CRAP > 30`, with a `--threshold` override.
The first supported coverage format is DMD/LDC `.lst` line coverage,
generated externally or by the tool through a convenience test runner.

Use DUB as the project/build/test runner. Add `unit-threaded` as the test
dependency and write the test suite with it.

Primary use case: audit D project quality, especially AI-generated code.

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

In progress:

- Gate-oriented analyze-only CLI behavior. Deterministic JSON serialization is
  in place; the next slice is threshold parsing and nonzero failure exit.

Still pending:

- D-aware cyclomatic complexity extraction.
- Method, constructor, destructor, overload, and filtering golden tests.
- Source-root and coverage-input discovery for analyze-only CLI mode.
- Convenience coverage-running mode.

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
- Compute cyclomatic complexity with a D-Scanner-compatible model:
  - base complexity `1`
  - count D-Scanner-style branch/control constructs, including conditionals,
    loops, switch cases, boolean short-circuit operators, ternaries,
    throws/catches, returns/breaks/continues/gotos, and function literals where
    that model counts them
- Parse DMD/LDC `.lst` files:
  - numeric count before `|` means executable covered line
  - `0000000|` means executable uncovered line
  - blank before `|` means non-executable line
- Map coverage to functions by source file plus function line range.
- Missing coverage for a parsed function is treated as `0%`.
- Exclude dependencies and generated files by default.
- Exclude test code by default.
- CTFE coverage is not first-class in v1; document that CTFE-generated `.lst`
  files may be analyzed as normal input.

## CLI Behavior

- Provide analyze-only mode:
  - input source roots
  - input coverage directory or `.lst` files
  - deterministic JSON output by default
- Provide convenience mode to run coverage:
  - run `dub test` with DMD/LDC coverage settings
  - write coverage output to a controlled directory using `DRT_COVOPT`
  - then analyze generated `.lst` files
- Output fields:
  - qualified function name
  - file path
  - line range
  - cyclomatic complexity
  - covered executable lines
  - total executable lines
  - coverage percent
  - CRAP score
- Exit nonzero when any scored function exceeds `--threshold`, default `30`.
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
- CLI integration test against a tiny DUB project using generated `.lst`
  fixtures, plus one optional live `dub test` coverage smoke test when D
  tooling is available.

## Assumptions

- v1 optimizes for practical DMD/LDC line coverage, not branch/path coverage.
- Test code is excluded by default because you chose product-code-focused
  scoring; later versions can add `--include-tests`.
- Dependencies and generated files are excluded by default, with explicit
  include/ignore flags.
- The evaluator may add dependencies as needed; local installed tools are not
  constraints.
