package db

import (
	"context"
	"embed"
	"fmt"
	"sort"
	"strings"
)

//go:embed schema/*.sql
var migrationFS embed.FS

func ApplyMigrations(ctx context.Context, database *DB) error {
	if _, err := database.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, applied_at TEXT NOT NULL)`); err != nil {
		return err
	}
	entries, err := migrationFS.ReadDir("schema")
	if err != nil {
		return err
	}
	names := make([]string, 0, len(entries))
	for _, entry := range entries {
		if !entry.IsDir() && strings.HasSuffix(entry.Name(), ".sql") {
			names = append(names, entry.Name())
		}
	}
	sort.Strings(names)
	for _, name := range names {
		version := strings.TrimSuffix(name, ".sql")
		var exists int
		if err := database.QueryRowContext(ctx, `SELECT COUNT(*) FROM schema_migrations WHERE version = ?`, version).Scan(&exists); err != nil {
			return err
		}
		if exists > 0 {
			continue
		}
		sqlText, err := migrationFS.ReadFile("schema/" + name)
		if err != nil {
			return err
		}
		tx, err := database.BeginTx(ctx, nil)
		if err != nil {
			return err
		}
		if _, err := tx.ExecContext(ctx, string(sqlText)); err != nil {
			_ = tx.Rollback()
			return fmt.Errorf("%s: %w", name, err)
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO schema_migrations (version, applied_at) VALUES (?, datetime('now'))`, version); err != nil {
			_ = tx.Rollback()
			return err
		}
		if err := tx.Commit(); err != nil {
			return err
		}
	}
	return nil
}
