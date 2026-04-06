#!/usr/bin/env node
// Test: Instinct file format validation

"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert");
const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");
const INSTINCTS_DIR = path.join(ROOT, "instincts");

describe("Instinct format validation", () => {
  const instinctFiles = fs
    .readdirSync(INSTINCTS_DIR)
    .filter((f) => f.endsWith(".md"));

  for (const file of instinctFiles) {
    describe(file, () => {
      // Normalize line endings for cross-platform compatibility (CRLF -> LF)
      const content = fs
        .readFileSync(path.join(INSTINCTS_DIR, file), "utf8")
        .replace(/\r\n/g, "\n");

      it("has YAML frontmatter delimiters", () => {
        assert.ok(content.startsWith("---\n"), "Missing opening ---");
        const secondDelim = content.indexOf("---", 4);
        assert.ok(secondDelim > 4, "Missing closing ---");
      });

      it("has required frontmatter fields", () => {
        const requiredFields = ["id", "trigger", "confidence", "domain", "source", "scope"];
        for (const field of requiredFields) {
          assert.ok(
            content.includes(`${field}:`),
            `Missing frontmatter field: ${field}`
          );
        }
      });

      it("has a confidence score between 0 and 1", () => {
        const match = content.match(/confidence:\s*([\d.]+)/);
        assert.ok(match, "No confidence score found");
        const confidence = parseFloat(match[1]);
        assert.ok(
          confidence > 0 && confidence <= 1,
          `Confidence ${confidence} out of range (0, 1]`
        );
      });

      it("has an Evidence section", () => {
        assert.ok(
          content.includes("## Evidence"),
          "Missing ## Evidence section"
        );
      });

      it("has an Action section", () => {
        assert.ok(
          content.includes("## Action") || content.includes("## Resolution"),
          "Missing ## Action or ## Resolution section"
        );
      });
    });
  }
});
