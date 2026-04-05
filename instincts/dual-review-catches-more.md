---
id: dual-review-catches-more
trigger: "when reviewing code before pushing"
confidence: 0.9
domain: security
source: session-observation
scope: global
created_at: "2026-04-05"
---

# Dual-Review Catches More Than Single Review

## Action
Run two independent reviewers with different focus areas (security + quality) in parallel. Neither reviewer should have written the code. Compare findings — overlapping issues are highest confidence, unique findings from each are the bonus.

## Evidence
- Session 2026-04-05: Security reviewer found 11 issues, Quality reviewer found 12 issues
- 5 issues found by BOTH (highest confidence): hardcoded creds, IDOR, token expiry, body size, input validation
- 4 issues found only by Security: rate limiting, timing attack, HTTPS, headers
- 3 issues found only by Quality: empty title on PUT, error handler ignoring status, unused dependency
- Total unique issues: 16 (vs ~11 from single reviewer)

## Pattern
Overlapping findings = fix immediately. Single-reviewer findings = evaluate case-by-case.
