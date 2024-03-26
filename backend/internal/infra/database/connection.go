package database

import "context"

type Connection interface {
	Query(context context.Context, statement string, data ...interface{}) (interface{}, error)
	Close() error
}
