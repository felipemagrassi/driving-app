require_relative 'command'

require_relative 'account_dao_postgres'
require_relative 'ride_dao_postgres'

require_relative 'signup'
require_relative 'get_account'

require_relative 'request_ride'
require_relative 'accept_ride'
require_relative 'start_ride'
require_relative 'get_ride'

require 'sinatra'
require 'json'

account_dao = AccountDAOPostgres.new
ride_dao = RideDAOPostgres.new

signup = Signup.new(account_dao:)
get_account = GetAccount.new(account_dao:)

request_ride = RequestRide.new(ride_dao:, account_dao:)
accept_ride = AcceptRide.new(ride_dao:, account_dao:)
start_ride = StartRide.new(account_dao:, ride_dao:)
get_ride = GetRide.new(ride_dao:)

get '/' do
  'Hello World!'
end

post('/signup') do
  command = SignupCommand.new(JSON.parse(request.body.read))
  content_type :json
  status 201
  body signup.execute(command).to_json
rescue StandardError
  status 400
end

get('/account/:account_id') do
  status 200
  content_type :json
  body get_account.execute(params[:account_id]).to_json
rescue StandardError
  status 404
end

post('/request-ride') do
  body = JSON.parse(request.body.read)
  command = RequestRideCommand.new(body)

  content_type :json
  status 201
  body request_ride.execute(command).to_json
rescue StandardError => e
  status 400
  puts e.message, e.backtrace
  body({ result: 'error', message: e.message }.to_json)
end

post('/accept-ride') do
  command = AcceptRideCommand.new(JSON.parse(request.body.read))
  content_type :json
  status 201
  body accept_ride.execute(command).to_json
end

post('/start-ride') do
  body = JSON.parse(request.body.read)
  command = StartRideCommand.new(body)
  content_type :json
  status 201
  body start_ride.execute(command[:ride_id]).to_json
end

get('/ride/:ride_id') do
  status 200
  content_type :json
  body get_ride.execute(params[:ride_id]).to_json
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

class StartRideCommand
  include Command
  attr_accessor :ride_id

  def [](key)
    send(key)
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
