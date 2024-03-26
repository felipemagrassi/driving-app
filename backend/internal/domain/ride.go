package domain

import (
	"time"

	"github.com/felipemagrassi/driving-app/pkg/entity"
)

type Ride struct {
	rideID       string
	passengerID  string
	driverID     string
	status       string
	happened_at  time.Time
	fromLat      float64
	toLat        float64
	fromLong     float64
	toLong       float64
	fare         float64
	distance     float64
	lastPosition string
}

func NewRide(passenger_id string, fromLat, toLat, fromLong, toLong float64) *Ride {
	return &Ride{
		rideID:      entity.NewID(),
		status:      "requested",
		happened_at: time.Now(),
		passengerID: passenger_id,
		fromLat:     fromLat,
		fromLong:    fromLong,
		toLat:       toLat,
		toLong:      toLong,
	}
}
