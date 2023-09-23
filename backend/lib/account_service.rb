# frozen_string_literal: true

require 'securerandom'
require 'pg'

require_relative 'cpf_validator'
require_relative 'account_dao'

class AccountService
  attr_reader :cpf_validator, :account_dao

  def initialize
    @cpf_validator = CpfValidator.new
    @account_dao = AccountDAO.new
  end

  def send_email(email, subject, message)
    puts "Sending email to #{email} with subject #{subject} and message #{message}"
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

    send_email(input[:email], 'Welcome to our app', 'You are now able to use our app')

    { account_id: }
  end

  def account(account_id)
    account_dao.find_by_account_id(account_id)
  end
end
