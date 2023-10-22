class Ride
  attr_reader :ride_id, :passenger_id, :from_lat, :from_lng, :to_lat, :to_lng, :status, :date, :driver_id, :fare,
              :distance

  def initialize(ride_id, passenger_id, from_lat, from_long, to_lat, to_long, status, date, driver_id, fare, distance)
    @ride_id = ride_id
    @passenger_id = passenger_id
    @from_lat = from_lat
    @from_lng = from_long
    @to_lat = to_lat
    @to_lng = to_long
    @status = status
    @date = date
    @driver_id = driver_id
    @fare = fare
    @distance = distance
  end

  def self.create(passenger_id, from_lat, from_lng, to_lat, to_lng)
    ride_id = SecureRandom.uuid
    status = 'requested'
    date = Time.now

    Ride.new(ride_id, passenger_id, from_lat, from_lng, to_lat, to_lng, status, date, nil, 0, 0)
  end

  def self.restore(ride_id, passenger_id, from_lat, from_lng, to_lat, to_lng, status, date, driver_id, fare, distance)
    Ride.new(ride_id, passenger_id, from_lat, from_lng, to_lat, to_lng, status, date, driver_id, fare, distance)
  end

  def accept!(driver_id)
    raise 'Ride status is not requested' if status != 'requested'

    self.status = 'accepted'
    self.driver_id = driver_id
  end

  def start!
    raise 'Ride status is not accepted' if status != 'accepted'

    self.status = 'in_progress'
  end

  def complete!
    raise 'Ride status is not in progress' if status != 'in_progress'

    self.status = 'completed'
  end

  private

  attr_writer :status, :driver_id
end
