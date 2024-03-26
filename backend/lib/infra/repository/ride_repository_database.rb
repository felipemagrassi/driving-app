require_relative '../../domain/ride'

class RideRepositoryDatabase
  def initialize(connection:)
    @connection = connection
  end

  def find_by_id(ride_id)
    result = connection.query('SELECT * FROM cccat13.ride WHERE ride_id = $1', [ride_id])
    return if result.first.nil?

    ride(result.first)
  end

  def find_active_rides_by_passenger_id(passenger_id)
    result = connection.query("SELECT * FROM cccat13.ride WHERE passenger_id = $1 AND status <> 'completed'",
                              [passenger_id])

    return if result.first.nil?

    ride(result.first)
  end

  def find_active_rides_by_driver_id(driver_id)
    result = connection.query("SELECT * FROM cccat13.ride WHERE driver_id = $1 AND status <> 'completed'", [driver_id])

    return if result.first.nil?

    ride(result.first)
  end

  def update(input)
    connection.query(
      'UPDATE cccat13.ride SET status = $1, driver_id = $2 WHERE ride_id = $3',
      [input.status, input.driver_id, input.ride_id]
    )
  end

  def save(input)
    raise ArgumentError unless input.is_a?(Ride)

    connection.query(
      'INSERT INTO
        cccat13.ride (ride_id, driver_id, passenger_id, from_lat, from_long, to_lat, to_long, date, status, fare, distance)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)', [
          input.ride_id, input.driver_id, input.passenger_id, input.from_lat, input.from_lng, input.to_lat, input.to_lng, input.date, input.status, input.fare, input.distance
        ]
    )
  end

  private

  attr_reader :connection

  def ride(input)
    input = input.transform_keys(&:to_sym)

    Ride.restore(
      input[:ride_id],
      input[:passenger_id], input[:from_lat],
      input[:from_long], input[:to_lat],
      input[:to_long], input[:status],
      input[:date], input[:driver_id],
      input[:fare], input[:distance]
    )
  end
end
