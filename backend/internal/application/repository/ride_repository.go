package repository

type RideRepository interface {
	Save(ride *Ride) error
	Update(ride *Ride) error
}
