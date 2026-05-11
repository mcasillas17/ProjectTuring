import fs from "node:fs";
import path from "node:path";
import type { TuringDatabase } from "./connection.js";

const MIGRATIONS_DIR = path.resolve(new URL(".", import.meta.url).pathname, "../../migrations");

export function applyMigrations(db: TuringDatabase, migrationsDir = MIGRATIONS_DIR): void {
  const files = fs.readdirSync(migrationsDir).filter((file) => file.endsWith(".sql")).sort();
  db.exec("CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, applied_at TEXT NOT NULL)");

  const applied = db.prepare("SELECT version FROM schema_migrations").all() as Array<{ version: string }>;
  const appliedSet = new Set(applied.map((row) => row.version));

  const insert = db.prepare("INSERT INTO schema_migrations (version, applied_at) VALUES (?, ?)");
  const runMigration = db.transaction((file: string) => {
    const sql = fs.readFileSync(path.join(migrationsDir, file), "utf8");
    db.exec(sql);
    insert.run(file, new Date().toISOString());
  });

  for (const file of files) {
    if (!appliedSet.has(file)) runMigration(file);
  }
}
