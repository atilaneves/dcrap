# Mistakes

## Approval request omitted required context

- Mistake: Asked the user to approve a proposed test without including the
  actual test code in the same message.
- Impact: The user had to ask where the test was before they could make the
  requested approval decision.
- Avoidance: When repository rules require approval for concrete proposed test
  code, include the full readable test code in the approval request message,
  even if it appeared earlier in a subagent result or prior turn.

## Hand-rolled exception assertion instead of project helper

- Mistake: Proposed a manual `try`/`catch` test for an expected exception when
  the project already has `shouldThrowWithMessage`.
- Impact: The proposed test was more verbose, less idiomatic, and easier to get
  subtly wrong than the existing assertion helper.
- Avoidance: Before proposing exception tests, check the local test helpers and
  use the project's established assertion style, including
  `shouldThrowWithMessage` when asserting exception messages.

## Ignored fluent assertion style

- Mistake: Proposed `shouldThrowWithMessage!Exception(expression, message)`
  instead of the project's more readable fluent style,
  `expression.shouldThrowWithMessage(message)`.
- Impact: The proposed test was noisier than surrounding tests and did not use
  the local assertion style the reviewer expected.
- Avoidance: Match the shortest established fluent assertion form in tests
  before proposing new test code.
