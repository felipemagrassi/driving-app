require 'securerandom'
require_relative 'account_dao_postgres'
require_relative 'ride_dao_postgres'

class RideService
  attr_reader :account_dao, :ride_dao

  def initialize(account_dao: AccountDAOPostgres.new, ride_dao: RideDAOPostgres.new)
    @account_dao = account_dao
    @ride_dao = ride_dao
  end

  def request_ride(input)
    ride_id = SecureRandom.uuid
    account = account_dao.find_by_account_id(input[:passenger_id])
    raise 'Account is not a passenger' if account[:is_passenger] == false
    raise 'Passenger already in a ride' if ride_dao.find_active_rides_by_passenger_id(input[:passenger_id])

    ride = input.to_h.merge(ride_id: ride_id, status: 'requested', fare: 0, distance: 0, date: Time.now)
    ride_dao.save(ride)

    { ride_id: }
  end

  def accept_ride(input)
    driver = account_dao.find_by_account_id(input[:driver_id])

    raise 'Account is not a driver' if driver[:is_driver] == false
    raise 'Ride status is not requested' if ride(input[:ride_id])[:status] != 'requested'
    raise 'Driver already in a ride' if ride_dao.find_active_rides_by_driver_id(input[:driver_id])

    ride_dao.update({ status: 'accepted', driver_id: input[:driver_id], ride_id: input[:ride_id] })
  end

  def ride(ride_id)
    ride_dao.find_by_id(ride_id)
  end
end
