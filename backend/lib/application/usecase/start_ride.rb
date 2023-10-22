require_relative '../../infra/command'

class StartRide
  attr_reader :account_dao, :ride_dao

  def initialize(account_dao:, ride_dao:)
    @account_dao = account_dao
    @ride_dao = ride_dao
  end

  def execute(ride_id)
    ride = ride_dao.find_by_id(ride_id)
    ride.start!

    ride_dao.update(ride)
  end
  alias call execute
end

class StartRideCommand
  include Command
  attr_accessor :ride_id

  def [](key)
    send(key)
  end
end
