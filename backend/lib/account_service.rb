# frozen_string_literal: true

require 'securerandom'
require 'pg'

require_relative 'cpf_validator'

class AccountService
  attr_reader :cpf_validator

  def initialize
    @cpf_validator = CpfValidator.new
  end

  def send_email(email, subject, message)
    puts "Sending email to #{email} with subject #{subject} and message #{message}"
  end

  def signup(input)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    account_id = SecureRandom.uuid

    account = connection.exec("SELECT account_id FROM cccat13.account WHERE email = '#{input[:email]}'").first

    raise 'Account already exists' if account
    raise ArgumentError, 'Invalid Name' unless input[:name].match?(/[a-zA-Z] [a-zA-Z]+$/)
    raise ArgumentError, 'Invalid Email' unless input[:email].match?(/^(.*)@(.*)$/)
    raise ArgumentError, 'Invalid CPF' unless cpf_validator.validate(input[:cpf])

    raise ArgumentError, 'Invalid car plate' if input[:is_driver] && !input[:car_plate].match?(/[A-Z]{3}[0-9]{4}/)

    connection.exec('INSERT INTO cccat13.account
      (account_id, name, cpf, email, is_passenger, is_driver, date, is_verified, verification_code)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)',
                    [account_id, input[:name], input[:cpf], input[:email], input[:is_passenger], input[:is_driver],
                     Time.now, false, SecureRandom.uuid])

    send_email(input[:email], 'Welcome to our app', 'You are now able to use our app')

    { account_id: }
  ensure
    connection&.close
  end

  def account(account_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')

    row = connection.exec("SELECT account_id, name, cpf, email, is_passenger::int, is_driver::int,
      is_verified::int, verification_code
      FROM cccat13.account WHERE account_id = '#{account_id}'").first

    return if row.nil?

    {
      account_id: row['account_id'],
      email: row['email'],
      name: row['name'],
      cpf: row['cpf'],
      is_passenger: boolean(row['is_passenger']),
      is_driver: boolean(row['is_driver']),
      is_verified: boolean(row['is_verified']),
      verification_code: row['verification_code']
    }
  ensure
    connection&.close
  end

  private

  def boolean(input)
    input == '1'
  end
end
