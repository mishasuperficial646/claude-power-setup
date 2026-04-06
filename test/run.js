#!/usr/bin/env node
// Cross-platform test runner that discovers test files and passes them to node --test.
// Needed because `node --test test/*.test.js` relies on shell glob expansion,
// which doesn't work on Windows PowerShell.

"use strict";

const { execFileSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const testDir = path.join(__dirname);
const testFiles = fs
  .readdirSync(testDir)
  .filter((f) => f.endsWith(".test.js"))
  .map((f) => path.join(testDir, f));

if (testFiles.length === 0) {
  console.error("No test files found in test/");
  process.exit(1);
}

try {
  execFileSync(process.execPath, ["--test", ...testFiles], {
    stdio: "inherit",
  });
} catch (err) {
  process.exit(err.status || 1);
}
