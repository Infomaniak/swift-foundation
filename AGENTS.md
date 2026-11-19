# AGENTS.md

## Test coverage

- Maintain at least **80% production line coverage** for this package and for each library product.
- Aim for the same minimum in each executable Swift source file so a well-covered library does not hide an untested file.
- Add tests for uncovered behavior rather than removing code from reports, weakening assertions, or changing production behavior to improve a percentage.
- Use Swift Testing for new unit tests and retain existing regression coverage.

## Validation

- Run `swift build` and `swift test --enable-code-coverage` after changing code or tests.
- Aggregate coverage from both `InfomaniakFoundationTests` and `InfomaniakChunkingTests` binaries; a single test binary does not represent the entire package.
- Report production source coverage separately from test helpers and generated test-runner code.
- Protocol-only declarations and code omitted by compiler instrumentation have no measurable line coverage; do not report them as 100% covered.
- Report unavailable branch counters as unavailable, not as full coverage.
- For iOS validation, use the `InfomaniakFoundation-Package` scheme so both libraries and test targets are included.
