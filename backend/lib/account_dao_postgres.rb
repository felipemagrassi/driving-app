require 'pg'

class AccountDAOPostgres 
  def find_by_email(email)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    account(connection.exec("SELECT * FROM cccat13.account WHERE email = '#{email}'").first)
  ensure
    connection&.close
  end

  def find_by_account_id(account_id)
    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    account(connection.exec("SELECT * FROM cccat13.account WHERE account_id = '#{account_id}'").first)
  ensure
    connection&.close
  end

  def save(account)
    raise ArgumentError unless account.is_a?(Account)

    connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
    connection.exec('INSERT INTO cccat13.account
                    (account_id, name, cpf, email, is_passenger, is_driver, date, is_verified, verification_code)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)',
                    [account.account_id, account.name, account.cpf, account.email,
                     account.is_passenger, account.is_driver,
                     account.date, account.is_verified, account.verification_code])
  ensure
    connection&.close
  end

  private

  def account(account)
    account['is_passenger'] = account['is_passenger'] == 't'
    account['is_driver'] = account['is_driver'] == 't'
    account['is_verified'] = account['is_verified'] == 't'

    Account.restore(account)
  end
end
