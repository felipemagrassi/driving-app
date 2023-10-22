class RequestRide
  attr_reader :account_dao, :ride_dao

  def initialize(account_dao:, ride_dao:)
    @account_dao = account_dao
    @ride_dao = ride_dao
  end

  def execute(input)
    account = account_dao.find_by_account_id(input[:passenger_id])

    raise 'Account is not a passenger' if account.is_passenger == false
    raise 'Passenger already in a ride' if ride_dao.find_active_rides_by_passenger_id(input[:passenger_id])

    ride = Ride.create(input[:passenger_id], input[:from][:lat], input[:from][:lng], input[:to][:lat], input[:to][:lng])
    ride_dao.save(ride)

    { ride_id: ride.ride_id }
  end
  alias call execute
end

class RequestRideCommand
  include Command

  attr_accessor :passenger_id
  attr_reader :from, :to

  def from=(from)
    @from = from.deep_transform_keys!(&:to_sym)
  end

  def to=(to)
    @to = to.deep_transform_keys!(&:to_sym)
  end

  def [](key)
    send(key)
  end

  def to_h
    {
      passenger_id:,
      from: {
        lat: from[:lat],
        lng: from[:lng]
      },
      to: {
        lat: to[:lat],
        lng: to[:lng]
      }
    }
  end
end
