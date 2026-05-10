import Database from "better-sqlite3";
import { describe, expect, it } from "vitest";
import { applyMigrations } from "../src/db/migrations.js";

describe("migrations", () => {
  it("creates the v1 schema", () => {
    const db = new Database(":memory:");
    applyMigrations(db);

    const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").all() as Array<{ name: string }>;
    expect(tables.map((row) => row.name)).toContain("sessions");
    expect(tables.map((row) => row.name)).toContain("jobs");
    expect(tables.map((row) => row.name)).toContain("audit_logs");
  });
});
