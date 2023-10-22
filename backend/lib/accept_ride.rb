require 'securerandom'

class AcceptRide
  attr_reader :account_dao, :ride_dao

  def initialize(account_dao:, ride_dao:)
    @account_dao = account_dao
    @ride_dao = ride_dao
  end

  def execute(input)
    driver = account_dao.find_by_account_id(input[:driver_id])
    ride = ride_dao.find_by_id(input[:ride_id])

    raise 'Account is not a driver' if driver.is_driver == false
    raise 'Driver already in a ride' if ride_dao.find_active_rides_by_driver_id(input[:driver_id])

    ride.accept!(input[:driver_id])

    ride_dao.update(ride)
  end
  alias call execute
end
