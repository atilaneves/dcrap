# Mistakes

## Approval request omitted required context

- Mistake: Asked the user to approve a proposed test without including the
  actual test code in the same message.
- Impact: The user had to ask where the test was before they could make the
  requested approval decision.
- Avoidance: When repository rules require approval for concrete proposed test
  code, include the full readable test code in the approval request message,
  even if it appeared earlier in a subagent result or prior turn.
