class Ride
  attr_reader :ride_id, :passenger_id, :from_lat, :from_long, :to_lat, :to_long, :status, :date

  def initialize(ride_id, passenger_id, from_lat, from_long, to_lat, to_long, status, date)
    @ride_id = ride_id
    @passenger_id = passenger_id
    @from_lat = from_lat
    @from_long = from_long
    @to_lat = to_lat
    @to_long = to_long
    @status = status
    @date = date
  end

  def create(passenger_id, from_lat, from_long, to_lat, to_long)
    ride_id = SecureRandom.uuid
    status = 'requested'
    date = Time.now

    Ride.new(ride_id, passenger_id, from_lat, from_long, to_lat, to_long, status, date)
  end
end
