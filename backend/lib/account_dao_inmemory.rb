class AccountDAOInMemory < AccountDAO
  attr_reader :accounts

  def initialize
    super
    @accounts = []
  end

  def find_by_email(email)
    accounts.find { |account| account[:email] == email }
  end

  def find_by_account_id(account_id)
    accounts.find { |account| account[:account_id] == account_id }
  end

  def save(input)
    accounts << input
  end
end
