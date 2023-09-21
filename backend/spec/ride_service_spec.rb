require 'ride_service'
require 'account_service'

RSpec.describe RideService do
  it 'should request a ride' do
    input_signup = { name: 'John Doe',
                     email: "john.doe#{rand(1000)}@email.com",
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
                     email: "john.doe#{rand(1000)}@email.com",
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
  end

  it 'should accept a ride' do
  end
end

