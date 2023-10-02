require 'pg'
require_relative 'ride_dao'

class RideDAOPostgres < RideDAO
  def find_by_id(ride_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    connection.exec("SELECT * FROM cccat13.ride WHERE ride_id = '#{ride_id}'").first.transform_keys(&:to_sym)
  ensure
    connection&.close
  end

  def find_active_rides_by_passenger_id(passenger_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    connection.exec("SELECT * FROM cccat13.ride WHERE passenger_id = '#{passenger_id}' AND status <> 'completed'")
              .first
              &.transform_keys(&:to_sym)
  ensure
    connection&.close
  end

  def find_active_rides_by_driver_id(driver_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    connection.exec("SELECT * FROM cccat13.ride WHERE driver_id = '#{driver_id}' AND status <> 'completed'")
              .first
              &.transform_keys(&:to_sym)
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
        input[:ride_id], input[:driver_id], input[:passenger_id], input[:from][:lat], input[:from][:lng], input[:to][:lat], input[:to][:lng], input[:date], input[:status], input[:fare], input[:distance]
      ]
    )
  ensure
    connection&.close
  end
end
