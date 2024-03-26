
require_relative '../../domain/ride'

class RideRepositoryInMemory
  attr_reader :rides

  def initialize
    @rides = []
  end

  def find_by_id(ride_id)
    rides.find { |ride| ride.ride_id == ride_id }
  end

  def find_active_rides_by_passenger_id(passenger_id)
    rides.find { |ride| ride.passenger_id == passenger_id && ride.status != 'completed' }
  end

  def find_active_rides_by_driver_id(driver_id)
    rides.find { |ride| ride.driver_id == driver_id && ride.status != 'completed' }
  end

  def update(input)
    found_ride = rides.find { |ride| ride.ride_id == input.ride_id }
    raise 'Ride not found' unless found_ride

    rides.delete(found_ride)

    rides << input

    input
  end

  def save(input)
    raise ArgumentError unless input.is_a?(Ride)

    rides << input
  end
end
