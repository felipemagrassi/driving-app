require 'securerandom'

require_relative '../../lib/domain/ride'
require_relative '../../lib/infra/repository/ride_repository_database'
require_relative '../../lib/infra/repository/ride_repository_inmemory'
require_relative '../../lib/infra/database/pg_promise_adapter'

RSpec.shared_examples 'RideDAO Adapter' do
  it 'should save and find a ride by id' do
    passenger_id = SecureRandom.uuid

    ride_input = { passenger_id:,
                   from: { lat: '-23.5656', lng: '-46.6565' },
                   to: { lat: '-23.5656', lng: '-46.6565' },
                   date: Time.now, status: 'requested', fare: 0, distance: 0 }

    new_ride = Ride.create(passenger_id, ride_input[:from][:lat],
                           ride_input[:from][:lng], ride_input[:to][:lat],
                           ride_input[:to][:lng])

    ride_dao.save(new_ride)

    ride = ride_dao.find_by_id(new_ride.ride_id)

    expect(ride).to be_a(Ride)
    expect(ride.ride_id).to be_truthy
    expect(ride.passenger_id).to eq(passenger_id)
    expect(ride.from_lat).to eq('-23.5656')
    expect(ride.from_lng).to eq('-46.6565')
    expect(ride.to_lat).to eq('-23.5656')
    expect(ride.to_lng).to eq('-46.6565')
    expect(ride.date).to be_truthy
    expect(ride.status).to eq('requested')
    expect(ride.fare.to_s).to eq('0')
    expect(ride.distance.to_s).to eq('0')
  end

  it 'should be able to verify if a passenger has an active ride' do
    passenger_id = SecureRandom.uuid
    driver_id = SecureRandom.uuid

    ride_input = { passenger_id:, driver_id:, from: { lat: '-23.5656', lng: '-46.6565' },
                   to: { lat: '-23.5656', lng: '-46.6565' }, date: Time.now, status: 'requested', fare: 0, distance: 0 }

    completed_ride = Ride.create(passenger_id, ride_input[:from][:lat],
                                 ride_input[:from][:lng], ride_input[:to][:lat],
                                 ride_input[:to][:lng])

    completed_ride.accept!(driver_id)
    completed_ride.start!
    completed_ride.complete!

    ride_dao.save(completed_ride)

    completed_ride = ride_dao.find_active_rides_by_passenger_id(passenger_id)

    expect(completed_ride).to be_nil

    requested_ride = Ride.create(passenger_id, ride_input[:from][:lat],
                                 ride_input[:from][:lng], ride_input[:to][:lat],
                                 ride_input[:to][:lng])

    ride_dao.save(requested_ride)

    requested_ride = ride_dao.find_active_rides_by_passenger_id(passenger_id)

    expect(requested_ride).to be_truthy
    expect(requested_ride.ride_id).to be_truthy
    expect(requested_ride.status).to eq('requested')
  end

  it 'should be able to verify if a driver has an active ride' do
    passenger_id = SecureRandom.uuid
    driver_id = SecureRandom.uuid

    ride_input = { passenger_id:, driver_id:, from: { lat: '-23.5656', lng: '-46.6565' },
                   to: { lat: '-23.5656', lng: '-46.6565' }, date: Time.now, status: 'requested', fare: 0, distance: 0 }

    completed_ride = Ride.create(passenger_id, ride_input[:from][:lat],
                                 ride_input[:from][:lng], ride_input[:to][:lat],
                                 ride_input[:to][:lng])

    completed_ride.accept!(driver_id)
    completed_ride.start!
    completed_ride.complete!

    ride_dao.save(completed_ride)

    ride = ride_dao.find_by_id(completed_ride.ride_id)

    expect(ride).to be_truthy

    active_ride = ride_dao.find_active_rides_by_driver_id(driver_id)
    expect(active_ride).to be_nil

    ride = Ride.create(passenger_id, ride_input[:from][:lat],
                       ride_input[:from][:lng], ride_input[:to][:lat],
                       ride_input[:to][:lng])
    ride.accept!(driver_id)
    ride_dao.save(ride)

    ride = ride_dao.find_by_id(ride.ride_id)

    expect(ride).to be_truthy

    requested_ride = ride_dao.find_active_rides_by_driver_id(driver_id)

    expect(requested_ride).to be_truthy
    expect(requested_ride.ride_id).to be_truthy
    expect(requested_ride.driver_id).to eq(driver_id)
    expect(requested_ride.status).to eq('accepted')
  end

  it 'should update a ride' do
    passenger_id = SecureRandom.uuid
    driver_id = SecureRandom.uuid

    ride_input = { passenger_id:, driver_id:, from: { lat: '-23.5656', lng: '-46.6565' },
                   to: { lat: '-23.5656', lng: '-46.6565' }, date: Time.now, status: 'requested', fare: 0, distance: 0 }

    ride = Ride.create(passenger_id, ride_input[:from][:lat],
                       ride_input[:from][:lng], ride_input[:to][:lat],
                       ride_input[:to][:lng])

    ride_dao.save(ride)

    ride = ride_dao.find_by_id(ride.ride_id)

    expect(ride).to be_truthy
    expect(ride.status).to eq('requested')

    ride.accept!(driver_id)

    ride_dao.update(ride)

    updated_ride = ride_dao.find_by_id(ride.ride_id)

    expect(updated_ride).to be_truthy
    expect(updated_ride.status).to eq('accepted')
    expect(updated_ride.driver_id).to eq(driver_id)
  end
end

RSpec.describe RideRepositoryDatabase do
  after { connection.close }

  let(:ride_dao) { RideRepositoryDatabase.new(connection:) }

  context 'when using postgres adapter' do
    let(:connection) { PgPromiseAdapter.new }

    include_examples 'RideDAO Adapter', RideRepositoryDatabase
  end
end

RSpec.describe RideRepositoryInMemory do
  let(:ride_dao) { RideRepositoryInMemory.new }

  include_examples 'RideDAO Adapter', RideRepositoryInMemory
end
