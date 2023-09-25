# frozen_string_literal: true

require 'securerandom'
require 'pg'

require_relative 'cpf_validator'
require_relative 'account_dao_postgres'
require_relative 'mailer_gateway'

class AccountService
  attr_reader :cpf_validator, :account_dao, :mailer_gateway

  def initialize(cpf_validator: CpfValidator.new, account_dao: AccountDAOPostgres.new,
                 mailer_gateway: MailerGateway.new)
    @cpf_validator = cpf_validator
    @mailer_gateway = mailer_gateway
    @account_dao = account_dao
  end

  def signup(input)
    account_id = SecureRandom.uuid
    account = account_dao.find_by_email(input[:email])

    raise 'Account already exists' if account
    raise ArgumentError, 'Invalid Name' unless input[:name].match?(/[a-zA-Z] [a-zA-Z]+$/)
    raise ArgumentError, 'Invalid Email' unless input[:email].match?(/^(.*)@(.*)$/)
    raise ArgumentError, 'Invalid CPF' unless cpf_validator.validate(input[:cpf])

    raise ArgumentError, 'Invalid car plate' if input[:is_driver] && !input[:car_plate].match?(/[A-Z]{3}[0-9]{4}/)

    account_dao.save({
                       account_id:,
                       name: input[:name],
                       email: input[:email],
                       cpf: input[:cpf],
                       is_passenger: input[:is_passenger],
                       is_driver: input[:is_driver],
                       date: Time.now,
                       is_verified: false,
                       verification_code: SecureRandom.uuid
                     })

    mailer_gateway.send(input[:email], 'Welcome to our app', 'You are now able to use our app')

    { account_id: }
  end

  def account(account_id)
    account_dao.find_by_account_id(account_id)
  end
end
