class AccountDAOInMemory
  attr_reader :accounts

  def initialize
    @accounts = []
  end

  def find_by_email(email)
    accounts.find { |account| account.email == email }
  end

  def find_by_account_id(account_id)
    accounts.find { |account| account.account_id == account_id }
  end

  def save(input)
    raise ArgumentError unless input.is_a?(Account)

    accounts << input
  end
end
