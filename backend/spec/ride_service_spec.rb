require 'ride_service'
require 'account_service'

RSpec.describe RideService do
  it 'should request a ride' do
    input_signup = { name: 'John Doe',
                     email: "john.doe#{rand(100_000)}@email.com",
                     cpf: '96273263728',
                     is_passenger: true }
    account_service = AccountService.new
    output_signup = account_service.signup(input_signup)

    input_request_ride = { passenger_id: output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }
    ride_service = RideService.new
    output_request_ride = ride_service.request_ride(input_request_ride)
    expect(output_request_ride).to be_truthy
  end

  it 'should request and consult a ride' do
    input_signup = { name: 'John Doe',
                     email: "john.doe#{rand(100_000)}@email.com",
                     cpf: '96273263728',
                     is_passenger: true }
    account_service = AccountService.new
    output_signup = account_service.signup(input_signup)

    input_request_ride = { passenger_id: output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }
    ride_service = RideService.new
    output_request_ride = ride_service.request_ride(input_request_ride)
    ride = ride_service.ride(output_request_ride[:ride_id])

    expect(ride).to be_truthy
    expect(ride[:passenger_id]).to eq(output_signup[:account_id])
    expect(ride[:driver_id]).to be_nil
    expect(ride[:from_lat]).to eq(input_request_ride[:from][:lat].to_s)
    expect(ride[:from_long]).to eq(input_request_ride[:from][:lng].to_s)
    expect(ride[:to_lat]).to eq(input_request_ride[:to][:lat].to_s)
    expect(ride[:to_long]).to eq(input_request_ride[:to][:lng].to_s)
    expect(ride[:fare]).to eq(0.to_s)
    expect(ride[:distance]).to eq(0.to_s)
    expect(ride[:ride_id]).to be_truthy
    expect(ride[:status]).to eq('requested')
  end

  it 'should not accept ride from an account that is not a passenger' do
    input_signup = { name: 'John Doe',
                     email: "john.doe#{rand(100_000)}@email.com",
                     cpf: '96273263728',
                     is_passenger: false }
    account_service = AccountService.new
    output_signup = account_service.signup(input_signup)

    input_request_ride = { passenger_id: output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }
    ride_service = RideService.new
    expect { ride_service.request_ride(input_request_ride) }.to raise_error('Account is not a passenger')
  end

  it 'should not accept ride from an passenger that already is in a ride' do
    input_signup = { name: 'John Doe',
                     email: "john.doe#{rand(100_000)}@email.com",
                     cpf: '96273263728',
                     is_passenger: true }
    account_service = AccountService.new
    output_signup = account_service.signup(input_signup)

    input_request_ride = { passenger_id: output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }
    ride_service = RideService.new
    ride_service.request_ride(input_request_ride)
    expect { ride_service.request_ride(input_request_ride) }.to raise_error('Passenger already in a ride')
  end

  it 'should accept a ride' do
    passenger_signup_input = { name: 'John Doe',
                               email: "john.doe#{rand(100_000)}@email.com",
                               cpf: '96273263728',
                               is_passenger: true }
    account_service = AccountService.new
    passenger_output_signup = account_service.signup(passenger_signup_input)

    driver_signup_input = { name: 'John Doe',
                            email: "john.doe#{rand(100_000)}@email.com",
                            cpf: '96273263728',
                            car_plate: 'ABC1234',
                            is_driver: true }
    account_service = AccountService.new
    driver_signup_output = account_service.signup(driver_signup_input)

    input_request_ride = { passenger_id: passenger_output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }

    ride_service = RideService.new
    output_request_ride = ride_service.request_ride(input_request_ride)
    ride = ride_service.ride(output_request_ride[:ride_id])

    input_accept_ride = {
      ride_id: ride[:ride_id],
      driver_id: driver_signup_output[:account_id]
    }

    ride_service.accept_ride(input_accept_ride)
    accepted_ride = ride_service.ride(ride[:ride_id])
    expect(accepted_ride[:status]).to eq('accepted')
  end

  it 'should not accept a ride when account is not driver' do
    passenger_signup_input = { name: 'John Doe',
                               email: "john.doe#{rand(100_000)}@email.com",
                               cpf: '96273263728',
                               is_passenger: true }
    account_service = AccountService.new
    passenger_output_signup = account_service.signup(passenger_signup_input)

    driver_signup_input = { name: 'John Doe',
                            email: "john.doe#{rand(100_000)}@email.com",
                            cpf: '96273263728',
                            car_plate: 'ABC1234',
                            is_driver: false }
    account_service = AccountService.new
    driver_signup_output = account_service.signup(driver_signup_input)

    input_request_ride = { passenger_id: passenger_output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }

    ride_service = RideService.new
    output_request_ride = ride_service.request_ride(input_request_ride)
    ride = ride_service.ride(output_request_ride[:ride_id])

    input_accept_ride = {
      ride_id: ride[:ride_id],
      driver_id: driver_signup_output[:account_id]
    }

    expect { ride_service.accept_ride(input_accept_ride) }.to raise_error('Account is not a driver')
  end

  it 'should not accept a ride when ride status is not requested' do
    passenger_signup_input = { name: 'John Doe',
                               email: "john.doe#{rand(100_000)}@email.com",
                               cpf: '96273263728',
                               is_passenger: true }
    account_service = AccountService.new
    passenger_output_signup = account_service.signup(passenger_signup_input)

    driver_signup_input = { name: 'John Doe',
                            email: "john.doe#{rand(100_000)}@email.com",
                            cpf: '96273263728',
                            car_plate: 'ABC1234',
                            is_driver: true }
    account_service = AccountService.new
    driver_signup_output = account_service.signup(driver_signup_input)

    input_request_ride = { passenger_id: passenger_output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }

    ride_service = RideService.new
    output_request_ride = ride_service.request_ride(input_request_ride)
    ride = ride_service.ride(output_request_ride[:ride_id])

    input_accept_ride = {
      ride_id: ride[:ride_id],
      driver_id: driver_signup_output[:account_id]
    }

    ride_service.accept_ride(input_accept_ride)
    expect { ride_service.accept_ride(input_accept_ride) }.to raise_error('Ride status is not requested')
  end

  it 'should not accept a ride when driver is already in a ride' do
    passenger_signup_input = { name: 'John Doe',
                               email: "john.doe#{rand(100_000)}@email.com",
                               cpf: '96273263728',
                               is_passenger: true }
    account_service = AccountService.new
    second_passenger_output_signup = account_service.signup(passenger_signup_input)

    second_passenger_signup_input = { name: 'John Doe',
                                      email: "john.doe#{rand(100_000)}@email.com",
                                      cpf: '96273263728',
                                      is_passenger: true }
    passenger_output_signup = account_service.signup(second_passenger_signup_input)

    driver_signup_input = { name: 'John Doe',
                            email: "john.doe#{rand(100_000)}@email.com",
                            cpf: '96273263728',
                            car_plate: 'ABC1234',
                            is_driver: true }
    account_service = AccountService.new
    driver_signup_output = account_service.signup(driver_signup_input)

    input_second_request_ride = { passenger_id: second_passenger_output_signup[:account_id],
                                  from: { lat: -23.5656, lng: -46.6565 },
                                  to: { lat: -23.5656, lng: -46.6565 } }

    input_request_ride = { passenger_id: passenger_output_signup[:account_id],
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }

    ride_service = RideService.new
    output_request_ride = ride_service.request_ride(input_request_ride)
    output_request_second_ride = ride_service.request_ride(input_second_request_ride)
    ride = ride_service.ride(output_request_ride[:ride_id])
    second_ride = ride_service.ride(output_request_second_ride[:ride_id])

    input_accept_ride = {
      ride_id: ride[:ride_id],
      driver_id: driver_signup_output[:account_id]
    }

    input_accept_second_ride = {
      ride_id: second_ride[:ride_id],
      driver_id: driver_signup_output[:account_id]
    }

    ride_service.accept_ride(input_accept_ride)
    expect { ride_service.accept_ride(input_accept_second_ride) }.to raise_error('Driver already in a ride')
  end
end
