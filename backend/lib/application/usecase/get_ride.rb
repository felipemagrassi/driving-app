class GetRide
  attr_reader :ride_dao

  def initialize(ride_dao:)
    @ride_dao = ride_dao
  end

  def execute(ride_id)
    ride_dao.find_by_id(ride_id)
  end
  alias call execute
end
