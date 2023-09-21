require 'securerandom'
require 'pg'

class RideService
  attr_reader :account_service

  def initialize
    @account_service = AccountService.new
  end

  def request_ride(input)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    ride_id = SecureRandom.uuid

    account = account_service.account(input[:passenger_id])

    raise 'Account is not a passenger' if account[:is_passenger].nil?

    connection.exec(
      'INSERT INTO cccat13.ride (ride_id, passenger_id, from_lat, from_long, to_lat, to_long, date) VALUES ($1, $2, $3, $4, $5, $6, $7)', [
        ride_id, input[:passenger_id], input[:from][:lat], input[:from][:lng], input[:to][:lat], input[:to][:lng], Time.now
      ]
    )

    { ride_id: }
  ensure
    connection.close if connection
  end

  def ride(ride_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    row = connection.exec("SELECT passenger_id FROM cccat13.ride WHERE ride_id = '#{ride_id}'")[0]

    { passenger_id: row['passenger_id'] }
  ensure
    connection.close if connection
  end
end
