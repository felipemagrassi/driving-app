class Signup
  attr_reader :account_dao, :mailer_gateway

  def initialize(account_dao:,
                 mailer_gateway:)
    @account_dao = account_dao
    @mailer_gateway = mailer_gateway
  end

  def execute(input)
    existing_account = account_dao.find_by_email(input[:email])
    raise 'Account already exists' if existing_account

    account = Account.create(input[:name], input[:email], input[:cpf], input[:is_passenger], input[:is_driver],
                             input[:car_plate])

    account_dao.save(account)
    mailer_gateway.send(input[:email], 'Welcome to our app', 'You are now able to use our app')
    { account_id: account.account_id }
  end
  alias call execute
end

class SignupCommand
  include Command

  attr_accessor :name, :email, :cpf, :is_passenger, :is_driver, :car_plate

  def [](key)
    send(key)
  end
end
