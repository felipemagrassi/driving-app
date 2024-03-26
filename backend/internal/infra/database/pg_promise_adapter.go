package database

import (
	"context"
	"database/sql"
)

type PgPromiseAdapter struct {
	DB *sql.DB
}

func NewPgPromiseAdapter(db *sql.DB) *PgPromiseAdapter {
	return &PgPromiseAdapter{DB: db}
}

func (adapter *PgPromiseAdapter) Query(context context.Context, statement string, data ...interface{}) (*sql.Rows, error) {
	return adapter.DB.QueryContext(context, statement, data...)
}

func (adapter *PgPromiseAdapter) Close() error {
	return adapter.DB.Close()
}
