#!/usr/bin/env node
// Test: Package doesn't include bloat dependencies

"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert");
const path = require("path");

const ROOT = path.join(__dirname, "..");

describe("Package quality", () => {
  const pkg = require(path.join(ROOT, "package.json"));

  it("has no runtime dependencies (zero-dep CLI)", () => {
    const deps = Object.keys(pkg.dependencies || {});
    assert.deepStrictEqual(
      deps,
      [],
      `Unexpected runtime dependencies: ${deps.join(", ")}`
    );
  });

  it("does not include video/out directories in files list", () => {
    const files = pkg.files || [];
    for (const excluded of ["video/", "out/", "video", "out"]) {
      assert.ok(
        !files.includes(excluded),
        `package.json 'files' should not include: ${excluded}`
      );
    }
  });

  it("has required package metadata", () => {
    assert.ok(pkg.name, "Missing package name");
    assert.ok(pkg.version, "Missing version");
    assert.ok(pkg.description, "Missing description");
    assert.ok(pkg.license, "Missing license");
    assert.ok(pkg.bin, "Missing bin entry");
    assert.ok(pkg.bin["claude-power-setup"], "Missing bin.claude-power-setup");
  });

  it("bin entry points to cli.js", () => {
    assert.strictEqual(pkg.bin["claude-power-setup"], "cli.js");
  });
});
