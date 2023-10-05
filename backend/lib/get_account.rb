# frozen_string_literal: true

require 'securerandom'
require 'pg'

require_relative 'cpf_validator'
require_relative 'account_dao'
require_relative 'mailer_gateway'

class GetAccount
  attr_reader :cpf_validator, :account_dao, :mailer_gateway

  def initialize(account_dao: AccountDAOPostgres.new)
    @account_dao = account_dao
  end

  def execute(account_id)
    account_dao.find_by_account_id(account_id)
  end
  alias call execute
end
