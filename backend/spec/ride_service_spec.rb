require_relative '../lib/account_dao_inmemory'
require_relative '../lib/ride_dao_inmemory'

require_relative '../lib/signup'
require_relative '../lib/get_ride'
require_relative '../lib/accept_ride'
require_relative '../lib/start_ride'
require_relative '../lib/request_ride'

RSpec.describe 'Ride' do
  let(:account_dao) { AccountDAOInMemory.new }
  let(:ride_dao) { RideDAOInMemory.new }
  let(:signup) { Signup.new(account_dao:) }
  let(:get_ride) { GetRide.new(ride_dao:) }
  let(:accept_ride) { AcceptRide.new(account_dao:, ride_dao:) }
  let(:start_ride) { StartRide.new(account_dao:, ride_dao:) }
  let(:request_ride) { RequestRide.new(account_dao:, ride_dao:) }

  it 'should request and consult a ride' do
    input_signup = { name: 'John Doe',
                     email: "john.doe#{rand(100_000)}@email.com",
                     cpf: '96273263728',
                     is_passenger: true }

    output_signup = signup.execute(input_signup)

    input_request_ride = { passenger_id: output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }
    output_request_ride = request_ride.execute(input_request_ride)
    ride = get_ride.execute(output_request_ride[:ride_id])

    expect(ride).to be_truthy
    expect(ride.passenger_id).to eq(output_signup[:account_id])
    expect(ride.driver_id).to be_nil
    expect(ride.from_lat).to eq(input_request_ride[:from][:lat])
    expect(ride.from_lng).to eq(input_request_ride[:from][:lng])
    expect(ride.to_lat).to eq(input_request_ride[:to][:lat])
    expect(ride.to_lng).to eq(input_request_ride[:to][:lng])
    expect(ride.fare).to eq(0)
    expect(ride.distance).to eq(0)
    expect(ride.ride_id).to be_truthy
    expect(ride.status).to eq('requested')
  end

  it 'should not accept ride from an account that is not a passenger' do
    input_signup = { name: 'John Doe',
                     email: "john.doe#{rand(100_000)}@email.com",
                     cpf: '96273263728',
                     is_passenger: false }
    output_signup = signup.execute(input_signup)

    input_request_ride = { passenger_id: output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }
    expect { request_ride.execute(input_request_ride) }.to raise_error('Account is not a passenger')
  end

  it 'should not accept ride from an passenger that already is in a ride' do
    input_signup = { name: 'John Doe',
                     email: "john.doe#{rand(100_000)}@email.com",
                     cpf: '96273263728',
                     is_passenger: true }
    output_signup = signup.execute(input_signup)

    input_request_ride = { passenger_id: output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }
    request_ride.execute(input_request_ride)
    expect { request_ride.execute(input_request_ride) }.to raise_error('Passenger already in a ride')
  end

  it 'should be able to accept a ride and start it' do
    passenger_signup_input = { name: 'John Doe',
                               email: "john.doe#{rand(100_000)}@email.com",
                               cpf: '96273263728',
                               is_passenger: true }
    passenger_output_signup = signup.execute(passenger_signup_input)

    driver_signup_input = { name: 'John Doe',
                            email: "john.doe#{rand(100_000)}@email.com",
                            cpf: '96273263728',
                            car_plate: 'ABC1234',
                            is_driver: true }
    driver_signup_output = signup.execute(driver_signup_input)

    input_request_ride = { passenger_id: passenger_output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }

    output_request_ride = request_ride.execute(input_request_ride)
    ride = get_ride.execute(output_request_ride[:ride_id])

    input_accept_ride = {
      ride_id: ride.ride_id,
      driver_id: driver_signup_output[:account_id]
    }

    accept_ride.execute(input_accept_ride)
    accepted_ride = get_ride.execute(ride.ride_id)
    expect(accepted_ride.status).to eq('accepted')

    start_ride.execute(ride.ride_id)
    ride = get_ride.execute(ride.ride_id)

    expect(ride.status).to eq('in_progress')
  end
  it 'should not be able to accept a ride and start it with wrong status' do
    passenger_signup_input = { name: 'John Doe',
                               email: "john.doe#{rand(100_000)}@email.com",
                               cpf: '96273263728',
                               is_passenger: true }
    passenger_output_signup = signup.execute(passenger_signup_input)
    driver_signup_input = { name: 'John Doe',
                            email: "john.doe#{rand(100_000)}@email.com",
                            cpf: '96273263728',
                            car_plate: 'ABC1234',
                            is_driver: true }
    driver_signup_output = signup.execute(driver_signup_input)

    input_request_ride = { passenger_id: passenger_output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }

    output_request_ride = request_ride.execute(input_request_ride)
    ride = get_ride.execute(output_request_ride[:ride_id])

    expect { start_ride.execute(ride[:ride_id]) }.to raise_error
  end

  it 'should not accept a ride when account is not driver' do
    passenger_signup_input = { name: 'John Doe',
                               email: "john.doe#{rand(100_000)}@email.com",
                               cpf: '96273263728',
                               is_passenger: true }
    passenger_output_signup = signup.execute(passenger_signup_input)

    driver_signup_input = { name: 'John Doe',
                            email: "john.doe#{rand(100_000)}@email.com",
                            cpf: '96273263728',
                            car_plate: 'ABC1234',
                            is_driver: false }
    driver_signup_output = signup.execute(driver_signup_input)

    input_request_ride = { passenger_id: passenger_output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }

    output_request_ride = request_ride.execute(input_request_ride)
    ride = get_ride.execute(output_request_ride[:ride_id])

    input_accept_ride = {
      ride_id: ride.ride_id,
      driver_id: driver_signup_output[:account_id]
    }

    expect { accept_ride.execute(input_accept_ride) }.to raise_error('Account is not a driver')
  end

  it 'should not accept a ride when ride status is not requested' do
    passenger_signup_input = { name: 'John Doe',
                               email: "john.doe#{rand(100_000)}@email.com",
                               cpf: '96273263728',
                               is_passenger: true }
    passenger_output_signup = signup.execute(passenger_signup_input)

    driver_signup_input = { name: 'John Doe',
                            email: "john.doe#{rand(100_000)}@email.com",
                            cpf: '96273263728',
                            car_plate: 'ABC1234',
                            is_driver: true }
    driver_signup_output = signup.execute(driver_signup_input)

    input_request_ride = { passenger_id: passenger_output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }

    output_request_ride = request_ride.execute(input_request_ride)
    ride = get_ride.execute(output_request_ride[:ride_id])

    input_accept_ride = {
      ride_id: ride.ride_id,
      driver_id: driver_signup_output[:account_id]
    }

    accept_ride.execute(input_accept_ride)
    expect { accept_ride.execute(input_accept_ride) }.to raise_error
  end

  it 'should not accept a ride when driver is already in a ride' do
    passenger_signup_input = { name: 'John Doe',
                               email: "john.doe#{rand(100_000)}@email.com",
                               cpf: '96273263728',
                               is_passenger: true }
    second_passenger_output_signup = signup.execute(passenger_signup_input)

    second_passenger_signup_input = { name: 'John Doe',
                                      email: "john.doe#{rand(100_000)}@email.com",
                                      cpf: '96273263728',
                                      is_passenger: true }
    passenger_output_signup = signup.execute(second_passenger_signup_input)

    driver_signup_input = { name: 'John Doe',
                            email: "john.doe#{rand(100_000)}@email.com",
                            cpf: '96273263728',
                            car_plate: 'ABC1234',
                            is_driver: true }
    driver_signup_output = signup.execute(driver_signup_input)

    input_second_request_ride = { passenger_id: second_passenger_output_signup[:account_id],
                                  from: { lat: -23.5656, lng: -46.6565 },
                                  to: { lat: -23.5656, lng: -46.6565 } }

    input_request_ride = { passenger_id: passenger_output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }

    output_request_ride = request_ride.execute(input_request_ride)
    output_request_second_ride = request_ride.execute(input_second_request_ride)
    ride = get_ride.execute(output_request_ride[:ride_id])
    second_ride = get_ride.execute(output_request_second_ride[:ride_id])

    input_accept_ride = {
      ride_id: ride.ride_id,
      driver_id: driver_signup_output[:account_id]
    }

    input_accept_second_ride = {
      ride_id: second_ride.ride_id,
      driver_id: driver_signup_output[:account_id]
    }

    accept_ride.execute(input_accept_ride)
    expect { accept_ride.execute(input_accept_second_ride) }.to raise_error('Driver already in a ride')
  end
end
