---
id: uuid-esm-incompatibility-jest
trigger: "when using uuid package with Jest in CommonJS"
confidence: 0.95
domain: debugging
source: session-observation
scope: global
created_at: "2026-04-05"
---

# uuid v13+ Is ESM-Only — Use crypto.randomUUID() Instead

## Action
When generating UUIDs in a Node.js CommonJS project tested with Jest, use `crypto.randomUUID()` (built-in since Node 19) instead of the `uuid` package. uuid v13+ is ESM-only and will cause `SyntaxError: Unexpected token 'export'` in Jest CommonJS test environments.

## Evidence
- Session 2026-04-05: test agent encountered this exact error and fixed it by replacing `require('uuid')` with `require('crypto').randomUUID()`
- Quality reviewer flagged the leftover `uuid` package in package.json as an unused dependency

## Resolution
```js
// Instead of: const { v4: uuidv4 } = require('uuid');
const { randomUUID } = require('crypto');
// Use: randomUUID() instead of uuidv4()
```
Then: `npm uninstall uuid`
