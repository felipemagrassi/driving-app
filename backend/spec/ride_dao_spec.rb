require 'securerandom'
require_relative '../lib/ride_dao'
require_relative '../lib/ride_dao_postgres'

RSpec.shared_examples 'RideDAO Adapter' do
  ride_dao = described_class.new

  it 'should save and find a ride by id' do
    ride_id = SecureRandom.uuid
    passenger_id = SecureRandom.uuid

    ride_input = { ride_id:, passenger_id:,
                   from: { lat: '-23.5656', lng: '-46.6565' },
                   to: { lat: '-23.5656', lng: '-46.6565' },
                   date: Time.now, status: 'requested', fare: 0, distance: 0 }
    ride_dao.save(ride_input)

    ride = ride_dao.find_by_id(ride_input[:ride_id])
    expect(ride).to be_truthy
    expect(ride[:ride_id]).to eq(ride_id)
    expect(ride[:passenger_id]).to eq(passenger_id)
    expect(ride[:from_lat]).to eq('-23.5656')
    expect(ride[:from_long]).to eq('-46.6565')
    expect(ride[:to_lat]).to eq('-23.5656')
    expect(ride[:to_long]).to eq('-46.6565')
    expect(ride[:date]).to be_truthy
    expect(ride[:status]).to eq('requested')
    expect(ride[:fare]).to eq('0')
    expect(ride[:distance]).to eq('0')
  end

  it 'should be able to verify if a passenger has an active ride' do
    passenger_id = SecureRandom.uuid
    driver_id = SecureRandom.uuid
    completed_ride_id = SecureRandom.uuid

    completed_ride_input = { ride_id: completed_ride_id, passenger_id:,
                             driver_id:,
                             from: { lat: '-23.5656', lng: '-46.6565' },
                             to: { lat: '-23.5656', lng: '-46.6565' },
                             date: Time.now, status: 'completed', fare: 0, distance: 0 }

    ride_dao.save(completed_ride_input)

    completed_ride = ride_dao.find_active_rides_by_passenger_id(passenger_id)

    expect(completed_ride).to be_nil

    requested_ride_id = SecureRandom.uuid
    requested_ride_input = { ride_id: requested_ride_id, passenger_id:,
                             driver_id:,
                             from: { lat: '-23.5656', lng: '-46.6565' },
                             to: { lat: '-23.5656', lng: '-46.6565' },
                             date: Time.now, status: 'requested', fare: 0, distance: 0 }

    ride_dao.save(requested_ride_input)

    requested_ride = ride_dao.find_active_rides_by_passenger_id(passenger_id)

    expect(requested_ride).to be_truthy
    expect(requested_ride[:ride_id]).to eq(requested_ride_id)
    expect(requested_ride[:status]).to eq('requested')
  end

  it 'should be able to verify if a driver has an active ride' do
    passenger_id = SecureRandom.uuid
    driver_id = SecureRandom.uuid
    completed_ride_id = SecureRandom.uuid
    completed_ride_input = { ride_id: completed_ride_id,
                             passenger_id:,
                             driver_id:,
                             from: { lat: '-23.5656', lng: '-46.6565' },
                             to: { lat: '-23.5656', lng: '-46.6565' },
                             date: Time.now, status: 'completed', fare: 0, distance: 0 }

    ride_dao.save(completed_ride_input)
    ride = ride_dao.find_by_id(completed_ride_id)

    expect(ride).to be_truthy

    completed_ride = ride_dao.find_active_rides_by_driver_id(driver_id)
    expect(completed_ride).to be_nil

    requested_ride_id = SecureRandom.uuid
    requested_ride_input = { ride_id: requested_ride_id, driver_id:,
                             passenger_id:,
                             from: { lat: '-23.5656', lng: '-46.6565' },
                             to: { lat: '-23.5656', lng: '-46.6565' },
                             date: Time.now, status: 'requested', fare: 0, distance: 0 }

    ride_dao.save(requested_ride_input)
    ride = ride_dao.find_by_id(requested_ride_id)

    expect(ride).to be_truthy

    requested_ride = ride_dao.find_active_rides_by_driver_id(driver_id)

    expect(requested_ride).to be_truthy
    expect(requested_ride[:ride_id]).to eq(requested_ride_id)
    expect(requested_ride[:driver_id]).to eq(driver_id)
    expect(requested_ride[:status]).to eq('requested')
  end

  it 'should update a ride' do
    passenger_id = SecureRandom.uuid
    driver_id = SecureRandom.uuid
    requested_ride_id = SecureRandom.uuid
    requested_ride_input = { ride_id: requested_ride_id, driver_id:,
                             passenger_id:,
                             from: { lat: '-23.5656', lng: '-46.6565' },
                             to: { lat: '-23.5656', lng: '-46.6565' },
                             date: Time.now, status: 'requested', fare: 0, distance: 0 }
    ride_dao.save(requested_ride_input)

    ride = ride_dao.find_by_id(requested_ride_id)

    expect(ride).to be_truthy
    expect(ride[:status]).to eq('requested')

    update_input = { ride_id: requested_ride_id, driver_id:, status: 'completed' }
    ride_dao.update(update_input)

    updated_ride = ride_dao.find_by_id(requested_ride_id)

    expect(updated_ride).to be_truthy
    expect(updated_ride[:status]).to eq('completed')
    expect(updated_ride[:driver_id]).to eq(driver_id)
  end
end

RSpec.describe RideDAOPostgres do
  it_behaves_like 'RideDAO Adapter'
end