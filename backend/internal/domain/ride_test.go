package domain_test

import (
	"testing"

	"github.com/felipemagrassi/driving-app/internal/domain"
)

func TestCreateRide(t *testing.T) {
	ride := domain.NewRide("passenger_id", 0.0, 0.0, 0.0, 0.0)

	if ride.RideID == "" {
		t.Error("Expected rideID to be set")
	}

	if ride.Status != "requested" {
		t.Error("Expected status to be requested")
	}

	if ride.HappenedAt.IsZero() {
		t.Error("Expected happened_at to be set")
	}

	if ride.PassengerID != "passenger_id" {
		t.Error("Expected passengerID to be set")
	}

	if ride.FromLat != 0.0 {
		t.Error("Expected fromLat to be set")
	}

	if ride.ToLat != 0.0 {
		t.Error("Expected toLat to be set")
	}

	if ride.FromLong != 0.0 {
		t.Error("Expected fromLong to be set")
	}
	if ride.ToLong != 0.0 {
		t.Error("Expected toLong to be set")
	}
	if ride.Fare != 0.0 {
		t.Error("Expected fare to be set")
	}
}
