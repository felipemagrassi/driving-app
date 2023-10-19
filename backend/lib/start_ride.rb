require 'securerandom'

class StartRide
  attr_reader :account_dao, :ride_dao

  def initialize(account_dao:, ride_dao:)
    @account_dao = account_dao
    @ride_dao = ride_dao
  end

  def execute(ride_id)
    ride = ride_dao.find_by_id(ride_id)
    raise 'Ride status is not accepted' if ride[:status] != 'accepted'

    ride_dao.update({ status: 'in_progress', ride_id:, driver_id: ride[:driver_id] })
  end
  alias call execute
end
