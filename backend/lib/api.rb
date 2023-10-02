require_relative 'ride_service'
require_relative 'account_service'
require_relative 'command'

require_relative 'account_dao_postgres'
require_relative 'ride_dao_postgres'

require 'sinatra'
require 'json'

account_dao = AccountDAOPostgres.new
ride_dao = RideDAOPostgres.new

account_service = AccountService.new(account_dao: account_dao)
ride_service = RideService.new(account_dao: account_dao, ride_dao: ride_dao)

get '/' do
  'Hello World!'
end

post('/signup') do
  command = SignupCommand.new(JSON.parse(request.body.read))
  content_type :json
  status 201
  body account_service.signup(command).to_json
rescue StandardError
  status 400
end

get('/account/:account_id') do
  status 200
  content_type :json
  body account_service.account(params[:account_id]).to_json
rescue StandardError
  status 404
end

post('/request-ride') do
  body = JSON.parse(request.body.read)
  command = RequestRideCommand.new(body)

  content_type :json
  status 201
  body ride_service.request_ride(command).to_json
rescue StandardError => e
  status 400
  puts e.message, e.backtrace
  body({ result: 'error', message: e.message }.to_json)
end

post('/accept-ride') do
  command = AcceptRideCommand.new(JSON.parse(request.body.read))
  content_type :json
  status 201
  body ride_service.accept_ride(command).to_json
end

get('/ride/:ride_id') do
  status 200
  content_type :json
  body ride_service.ride(params[:ride_id]).to_json
end

error do
  content_type :json
  status 400
  e = env['sinatra.error']

  { result: 'error', message: e['message'] }.to_json
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

class AcceptRideCommand
  include Command

  attr_accessor :ride_id, :driver_id

  def [](key)
    send(key)
  end
end

class SignupCommand
  include Command

  attr_accessor :name, :email, :cpf, :is_passenger, :is_driver, :car_plate

  def [](key)
    send(key)
  end
end
