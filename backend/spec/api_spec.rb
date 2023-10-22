require 'http'

RSpec.describe 'API' do
  it 'should work' do
    expect(HTTP.get('http://localhost:4567').to_s).to eq('Hello World!')
  end

  it 'should create an passanger and retrieve an passanger' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_passenger: true }

    signup = HTTP.headers(content_type: 'application/json')
                 .post('http://localhost:4567/signup', json: input)

    account_id = JSON.parse(signup.body).account_id

    expect(signup.code).to eq(201)
    expect(account_id).to be_truthy

    account = JSON.parse(HTTP.get("http://localhost:4567/account/#{account_id}"))

    expect(account['name']).to eq(input[:name])
    expect(account['email']).to eq(input[:email])
    expect(account['cpf']).to eq(input[:cpf])
    expect(account['is_passenger']).to eq(input[:is_passenger])
  end

  it 'should be able to request, accept and start a ride' do
    passenger_input = { name: 'John Doe',
                        email: "john.doe#{rand(1000)}@email.com",
                        cpf: '96273263728',
                        is_passenger: true }

    driver_input = { name: 'John Doe',
                     email: "john.doe#{rand(1000)}@email.com",
                     cpf: '96273263728',
                     car_plate: 'AAA1234',
                     is_driver: true }

    passenger_signup = HTTP.headers(content_type: 'application/json')
                           .post('http://localhost:4567/signup', json: passenger_input)
    passenger_id = JSON.parse(passenger_signup.body)['account_id']
    passenger = JSON.parse(HTTP.get("http://localhost:4567/account/#{passenger_id}"))

    driver_signup = HTTP.headers(content_type: 'application/json')
                        .post('http://localhost:4567/signup', json: driver_input)
    driver_id = JSON.parse(driver_signup.body)['account_id']
    driver = JSON.parse(HTTP.get("http://localhost:4567/account/#{driver_id}"))

    expect(passenger).to be_truthy
    expect(driver).to be_truthy

    input_request_ride = { passenger_id:,
                           from: { lat: -23.5656, lng: -46.6565 },
                           to: { lat: -23.5656, lng: -46.6565 } }
    ride_request = HTTP.headers(content_type: 'application/json')
                       .post('http://localhost:4567/request-ride', json: input_request_ride)
    ride_id = JSON.parse(ride_request.body)['ride_id']
    ride = JSON.parse(HTTP.get("http://localhost:4567/ride/#{ride_id}"))

    expect(ride['passenger_id']).to eq(passenger_id)
    expect(ride['status']).to eq('requested')

    input_accept_ride = {
      ride_id:,
      driver_id:
    }

    HTTP.headers(content_type: 'application/json')
        .post('http://localhost:4567/accept-ride', json: input_accept_ride)

    ride = JSON.parse(HTTP.get("http://localhost:4567/ride/#{ride_id}"))

    expect(ride['driver_id']).to eq(driver_id)
    expect(ride['status']).to eq('accepted')

    HTTP.headers(content_type: 'application/json')
    .post('http://localhost:4567/start-ride', json: { ride_id: ride_id })

    ride = JSON.parse(HTTP.get("http://localhost:4567/ride/#{ride_id}"))

    expect(ride['status']).to eq('in_progress')

  end
end
