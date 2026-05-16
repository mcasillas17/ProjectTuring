package db

import (
	"database/sql"
	"fmt"

	_ "github.com/mattn/go-sqlite3"
)

type DB struct {
	*sql.DB
}

func Open(path string) (*DB, error) {
	database, err := sql.Open("sqlite3", fmt.Sprintf("file:%s?_foreign_keys=on&_journal_mode=WAL", path))
	if err != nil {
		return nil, err
	}
	database.SetMaxOpenConns(1)
	if err := database.Ping(); err != nil {
		_ = database.Close()
		return nil, err
	}
	return &DB{DB: database}, nil
}
