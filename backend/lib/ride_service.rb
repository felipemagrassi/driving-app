require 'securerandom'
require 'pg'

require 'account_dao'

class RideService
  attr_reader :account_dao

  def initialize(account_dao: AccountDAOPostgres.new)
    @account_dao = account_dao
  end

  def request_ride(input)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    ride_id = SecureRandom.uuid
    account = account_dao.find_by_account_id(input[:passenger_id])
    puts account
    raise 'Account is not a passenger' if account[:is_passenger] == false

    if connection.exec("SELECT ride_id FROM cccat13.ride WHERE passenger_id = '#{input[:passenger_id]}' AND status <> 'completed'").first
      raise 'Passenger already in a ride'
    end

    connection.exec(
      'INSERT INTO
      cccat13.ride (ride_id, passenger_id, from_lat, from_long, to_lat, to_long, date, status, fare, distance)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)', [
        ride_id, input[:passenger_id], input[:from][:lat], input[:from][:lng], input[:to][:lat], input[:to][:lng], Time.now, 'requested', 0, 0
      ]
    )
    { ride_id: }
  ensure
    connection.close if connection
  end

  def accept_ride(input)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')

    driver = account_dao.find_by_account_id(input[:driver_id])

    raise 'Account is not a driver' if driver[:is_driver] == false
    raise 'Ride status is not requested' if ride(input[:ride_id])[:status] != 'requested'
    if connection.exec("SELECT ride_id FROM cccat13.ride WHERE driver_id = '#{input[:driver_id]}' AND (status = 'accepted' OR status = 'in_progress')").first
      raise 'Driver already in a ride'
    end

    connection.exec(
      'UPDATE cccat13.ride SET status = $1, driver_id = $2 WHERE ride_id = $3', [
        'accepted', input[:driver_id], input[:ride_id]
      ]
    )
  ensure
    connection.close if connection
  end

  def ride(ride_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    row = connection.exec("SELECT passenger_id, ride_id, status, driver_id, from_lat, date, from_long, to_lat, to_long, fare, distance FROM cccat13.ride
      WHERE ride_id = '#{ride_id}'").first

    {
      passenger_id: row['passenger_id'], ride_id: row['ride_id'], status: row['status'], driver_id: row['driver_id'],
      date: row['date'], from_lat: row['from_lat'], from_long: row['from_long'], to_lat: row['to_lat'], to_long: row['to_long'],
      fare: row['fare'], distance: row['distance']
    }
  ensure
    connection.close if connection
  end
end
