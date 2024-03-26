package entity

import "github.com/google/uuid"

type ID = uuid.UUID

func NewID() string {
	return uuid.New().String()
}

func ParseID(s string) (string, error) {
	id, err := uuid.Parse(s)
	return id.String(), err
}
