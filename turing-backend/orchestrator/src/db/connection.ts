import Database from "better-sqlite3";

export type TuringDatabase = Database.Database;

export function openDatabase(path: string): TuringDatabase {
  const db = new Database(path);
  db.pragma("journal_mode = WAL");
  db.pragma("busy_timeout = 5000");
  db.pragma("foreign_keys = ON");
  return db;
}
