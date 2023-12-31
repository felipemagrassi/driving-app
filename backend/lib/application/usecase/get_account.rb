# frozen_string_literal: true
class GetAccount
  attr_reader :account_dao

  def initialize(account_dao:)
    @account_dao = account_dao
  end

  def execute(account_id)
    account_dao.find_by_account_id(account_id)
  end
  alias call execute
end
