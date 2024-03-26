require_relative "infra/command"

require_relative "infra/repository/account_repository_database"
require_relative "infra/repository/ride_repository_database"

require_relative "infra/database/pg_promise_adapter"

require_relative "infra/gateway/mailer_gateway"

require_relative "application/usecase/signup"
require_relative "application/usecase/get_account"

require_relative "application/usecase/request_ride"
require_relative "application/usecase/accept_ride"
require_relative "application/usecase/start_ride"
require_relative "application/usecase/get_ride"

require "sinatra"
require "json"

pg_connection = PgPromiseAdapter.new
account_dao = AccountRepositoryDatabase.new(connection: pg_connection)
ride_dao = RideRepositoryDatabase.new(connection: pg_connection)
mailer_gateway = MailerGateway.new

signup = Signup.new(account_dao:, mailer_gateway:)
get_account = GetAccount.new(account_dao:)

request_ride = RequestRide.new(ride_dao:, account_dao:)
accept_ride = AcceptRide.new(ride_dao:, account_dao:)
start_ride = StartRide.new(account_dao:, ride_dao:)
get_ride = GetRide.new(ride_dao:)

# This should become a controller with http adapter to remove sinatra dependency in the future

get("/") do
  "Hello World!"
end

post("/signup") do
  command = SignupCommand.new(JSON.parse(request.body.read))
  content_type(:json)
  status(201)
  body(signup.execute(command).to_json)
rescue StandardError => e
  puts(e.message, e.backtrace)
  status(400)
end

get("/account/:account_id") do
  status(200)
  content_type(:json)
  body(get_account.execute(params[:account_id]).to_h.to_json)
rescue StandardError
  puts(e.message, e.backtrace)
  status(404)
end

post("/request-ride") do
  body = JSON.parse(request.body.read)
  command = RequestRideCommand.new(body)

  content_type(:json)
  status(201)
  body request_ride.execute(command).to_json
rescue StandardError => e
  puts(e.message, e.backtrace)
  status(400)
  puts(e.message, e.backtrace)
  body({result: "error", message: e.message}.to_json)
end

post("/accept-ride") do
  command = AcceptRideCommand.new(JSON.parse(request.body.read))
  content_type(:json)
  status(201)
  body accept_ride.execute(command).to_json
rescue StandardError => e
  puts(e.message, e.backtrace)
end

post("/start-ride") do
  body = JSON.parse(request.body.read)
  command = StartRideCommand.new(body)
  content_type(:json)
  status(201)
  body start_ride.execute(command[:ride_id]).to_json
rescue StandardError => e
  puts(e.message, e.backtrace)
end

get("/ride/:ride_id") do
  status(200)
  content_type(:json)
  body get_ride.execute(params[:ride_id]).to_h.to_json
rescue StandardError => e
  puts(e.message, e.backtrace)
end

error do
  content_type(:json)
  status(400)
  e = env["sinatra.error"]

  {result: "error", message: e["message"]}.to_json
end
