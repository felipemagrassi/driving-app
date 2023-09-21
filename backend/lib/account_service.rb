# frozen_string_literal: true

require 'securerandom'
require 'pg'

class AccountService
  def initialize; end

  def send_email(email, subject, message)
    puts "Sending email to #{email} with subject #{subject} and message #{message}"
  end

  def signup(_input)
    account_id = SecureRandom.uuid

    { account_id: }
  end

  def account; end
end
