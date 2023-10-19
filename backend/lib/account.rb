require 'securerandom'
require_relative 'cpf_validator'

class Account
  attr_reader :account_id, :name, :email, :cpf, :is_passenger, :is_driver, :date, :is_verified, :verification_code,
              :car_plate

  def initialize(account_id, name, email, cpf, is_passenger, is_driver, date, is_verified, verification_code, car_plate)
    @account_id = account_id
    @name = name
    @email = email
    @cpf = cpf
    @is_passenger = is_passenger
    @is_driver = is_driver
    @date = date
    @is_verified = is_verified
    @verification_code = verification_code
    @car_plate = car_plate
  end

  def self.create(name, email, cpf, is_passenger, is_driver, car_plate)
    account_id = SecureRandom.uuid
    date = Time.now
    is_verified = false
    verification_code = SecureRandom.uuid
    cpf_validator = CpfValidator.new

    raise ArgumentError, 'Invalid Name' unless name.match?(/[a-zA-Z] [a-zA-Z]+$/)
    raise ArgumentError, 'Invalid Email' unless email.match?(/^(.*)@(.*)$/)
    raise ArgumentError, 'Invalid CPF' unless cpf_validator.validate(cpf)
    raise ArgumentError, 'Invalid car plate' if is_driver && !car_plate.match?(/[A-Z]{3}[0-9]{4}/)

    Account.new(account_id, name, email, cpf,
                is_passenger == true, is_driver == true,
                date, is_verified == true,
                verification_code, car_plate)
  end

  def self.restore(account)
    Account.new(account['account_id'],
                account['name'], account['email'], account['cpf'], account['is_passenger'],
                account['is_driver'], account['date'], account['is_verified'], account['verification_code'],
                account['car_plate'])
  end
end
