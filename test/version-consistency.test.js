#!/usr/bin/env node
// Test: All installers derive version from package.json (no hardcoded versions)

"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert");
const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");

describe("Version consistency", () => {
  const pkgVersion = require(path.join(ROOT, "package.json")).version;

  it("package.json has a valid semver version", () => {
    assert.match(pkgVersion, /^\d+\.\d+\.\d+/);
  });

  it("cli.js reads version from package.json (no hardcoded VERSION)", () => {
    const cli = fs.readFileSync(path.join(ROOT, "cli.js"), "utf8");
    // Should contain: require("./package.json").version
    assert.ok(
      cli.includes('require("./package.json").version'),
      "cli.js should read version from package.json"
    );
    // Should NOT contain a hardcoded version string like VERSION = "1.0.0"
    const hardcoded = cli.match(/VERSION\s*=\s*"(\d+\.\d+\.\d+)"/);
    assert.ok(
      !hardcoded,
      `cli.js has hardcoded version: ${hardcoded ? hardcoded[1] : "none"}`
    );
  });

  it("install.sh reads version from package.json (no hardcoded VERSION)", () => {
    const sh = fs.readFileSync(path.join(ROOT, "install.sh"), "utf8");
    // Should NOT have VERSION="X.Y.Z" as a standalone assignment (0.0.0 fallback is OK)
    const hardcoded = sh.match(/^VERSION="(\d+\.\d+\.\d+)"/m);
    assert.ok(
      !hardcoded || hardcoded[1] === "0.0.0",
      `install.sh has hardcoded version: ${hardcoded ? hardcoded[1] : "none"}`
    );
    // Should reference package.json
    assert.ok(
      sh.includes("package.json"),
      "install.sh should reference package.json for version"
    );
  });

  it("install.ps1 reads version from package.json (no hardcoded $Version)", () => {
    const ps1 = fs.readFileSync(path.join(ROOT, "install.ps1"), "utf8");
    // Should NOT have $Version = "X.Y.Z" where X.Y.Z is a real version (not 0.0.0 fallback)
    const hardcoded = ps1.match(/\$Version\s*=\s*"(\d+\.\d+\.\d+)"/g) || [];
    const realVersions = hardcoded.filter((m) => !m.includes('"0.0.0"'));
    assert.strictEqual(
      realVersions.length,
      0,
      `install.ps1 has hardcoded version: ${realVersions.join(", ")}`
    );
    // Should reference package.json
    assert.ok(
      ps1.includes("package.json"),
      "install.ps1 should reference package.json for version"
    );
  });
});
