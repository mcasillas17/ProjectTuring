import { describe, expect, it } from "vitest";
import { bearerTokenFromHeader, tokenMatches } from "../src/security/auth.js";

describe("auth helpers", () => {
  it("extracts bearer tokens", () => {
    expect(bearerTokenFromHeader("Bearer tk_test")).toBe("tk_test");
    expect(bearerTokenFromHeader("Basic nope")).toBeUndefined();
  });

  it("compares tokens without accepting empty values", () => {
    expect(tokenMatches("tk_test", "tk_test")).toBe(true);
    expect(tokenMatches("", "")).toBe(false);
    expect(tokenMatches("wrong", "tk_test")).toBe(false);
  });
});
