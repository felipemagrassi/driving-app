require 'pg'
require_relative 'ride'

class RideDAODatabase
  def find_by_id(ride_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    result = connection.exec("SELECT * FROM cccat13.ride WHERE ride_id = '#{ride_id}'")

    return if result.first.nil?

    ride(result.first)
  ensure
    connection&.close
  end

  def find_active_rides_by_passenger_id(passenger_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    result = connection.exec("SELECT * FROM cccat13.ride WHERE passenger_id = '#{passenger_id}' AND status <> 'completed'")

    return if result.first.nil?

    ride(result.first)
  ensure
    connection&.close
  end

  def find_active_rides_by_driver_id(driver_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    result = connection.exec("SELECT * FROM cccat13.ride WHERE driver_id = '#{driver_id}' AND status <> 'completed'")

    return if result.first.nil?

    ride(result.first)
  ensure
    connection&.close
  end

  def update(input)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    connection.exec(
      'UPDATE cccat13.ride SET status = $1, driver_id = $2 WHERE ride_id = $3',
      [input[:status], input[:driver_id], input[:ride_id]]
    )
  ensure
    connection&.close
  end

  def save(input)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    connection.exec(
      'INSERT INTO
      cccat13.ride (ride_id, driver_id, passenger_id, from_lat, from_long, to_lat, to_long, date, status, fare, distance)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)', [
        input.ride_id, input.driver_id, input.passenger_id, input.from_lat, input.from_lng, input.to_lat, input.to_lng, input.date, input.status, input.fare, input.distance
      ]
    )
  ensure
    connection&.close
  end

  private

  def ride(input)
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
