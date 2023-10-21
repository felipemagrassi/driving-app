require 'securerandom'

class RequestRide
  attr_reader :account_dao, :ride_dao

  def initialize(account_dao:, ride_dao:)
    @account_dao = account_dao
    @ride_dao = ride_dao
  end

  def execute(input)
    ride_id = SecureRandom.uuid
    account = account_dao.find_by_account_id(input[:passenger_id])
    raise 'Account is not a passenger' if account.is_passenger == false
    raise 'Passenger already in a ride' if ride_dao.find_active_rides_by_passenger_id(input[:passenger_id])

    ride = input.to_h.merge(ride_id:, status: 'requested', fare: 0, distance: 0, date: Time.now)
    ride_dao.save(ride)
    { ride_id: }
  end
  alias call execute
end
