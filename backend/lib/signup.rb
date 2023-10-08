# frozen_string_literal: true

require_relative 'account'
require_relative 'account_dao'
require_relative 'mailer_gateway'

class Signup
  attr_reader :cpf_validator, :account_dao, :mailer_gateway

  def initialize(cpf_validator: CpfValidator.new, account_dao: AccountDAOPostgres.new,
                 mailer_gateway: MailerGateway.new)
    @cpf_validator = cpf_validator
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
