package audit

import (
	"context"
	"database/sql"
	"fmt"
	"math"
	"strings"
	"testing"

	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/db"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/repository"
)

func openAuditTestDB(t *testing.T) *db.DB {
	t.Helper()
	name := strings.NewReplacer("/", "_", " ", "_", ":", "_").Replace(t.Name())
	sqlDB, err := sql.Open("sqlite3", fmt.Sprintf("file:%s?mode=memory&cache=shared&_foreign_keys=on", name))
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	sqlDB.SetMaxOpenConns(1)
	database := &db.DB{DB: sqlDB}
	t.Cleanup(func() { _ = database.Close() })
	if err := db.ApplyMigrations(context.Background(), database); err != nil {
		t.Fatalf("apply migrations: %v", err)
	}
	return database
}

func TestRecordStoresCanonicalPayload(t *testing.T) {
	database := openAuditTestDB(t)
	service := New(repository.New(database))

	if err := service.Record(context.Background(), "run_1", "client", "user_1", "approval.approved", "appr_1", map[string]any{"b": float64(2), "a": "one"}); err != nil {
		t.Fatal(err)
	}

	var payloadJSON string
	if err := database.QueryRowContext(context.Background(), `SELECT payload_json FROM audit_logs WHERE action = 'approval.approved'`).Scan(&payloadJSON); err != nil {
		t.Fatal(err)
	}
	if payloadJSON != `{"a":"one","b":2}` {
		t.Fatalf("payload_json = %s", payloadJSON)
	}
}

func TestRecordRejectsUnsafeDynamicPayload(t *testing.T) {
	database := openAuditTestDB(t)
	service := New(repository.New(database))

	err := service.Record(context.Background(), "run_1", "runtime", "worker_1", "tool.call.started", "call_1", map[string]any{"bad": math.NaN()})
	if err == nil {
		t.Fatal("Record succeeded with NaN payload, want error")
	}
}
