require_relative '../../domain/account'

class AccountRepositoryDatabase
  def initialize(connection:)
    @connection = connection
  end

  def find_by_email(email)
    result = connection.query('SELECT * FROM cccat13.account WHERE email = $1', [email])

    return if result.first.nil?

    account(result.first)
  end

  def find_by_account_id(account_id)
    result = connection.query('SELECT * FROM cccat13.account WHERE account_id = $1', [account_id])

    return if result.first.nil?

    account(result.first)
  end

  def save(account)
    raise ArgumentError unless account.is_a?(Account)

    connection.query('INSERT INTO cccat13.account
                    (account_id, name, cpf, email, is_passenger, is_driver, date, is_verified, verification_code)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)',
                     [account.account_id, account.name, account.cpf, account.email,
                      account.is_passenger, account.is_driver,
                      account.date, account.is_verified, account.verification_code])
  end

  private

  attr_reader :connection

  def account(account)
    account['is_passenger'] = account['is_passenger'] == 't'
    account['is_driver'] = account['is_driver'] == 't'
    account['is_verified'] = account['is_verified'] == 't'

    Account.restore(account['account_id'], account['name'], account['email'], account['cpf'], account['is_passenger'],
                    account['is_driver'], account['date'], account['is_verified'], account['verification_code'], account['car_plate'])
  end
end
