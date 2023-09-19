import SecureRandom

class AccountService
  def initialize; end

  # port
  def signup(input)
    input['id'] = SecureRandom.uuid
  end

  def getAccount; end
end
