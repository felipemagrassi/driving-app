require 'account_dao'
require 'account_dao_inmemory'
require 'account_dao_postgres'
require 'securerandom'

require 'account'

RSpec.shared_examples 'AccountDAO Adapter' do
  it 'should save an account and retrieve by email' do
    account_dao = described_class.new

    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_passenger: true,
              is_driver: false,
              car_plate: nil }

    account = Account.create(input[:name], input[:email], input[:cpf], input[:is_passenger],
                             input[:is_driver], input[:car_plate])

    account_dao.save(account)

    account = account_dao.find_by_email(input[:email])

    expect(account).to be_truthy
  end

  it 'should save an account and retrieve by account_id' do
    account_dao = described_class.new

    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_passenger: true,
              is_driver: false,
              car_plate: nil }

    account = Account.create(input[:name], input[:email], input[:cpf], input[:is_passenger],
                             input[:is_driver], input[:car_plate])

    account_dao.save(account)

    account = account_dao.find_by_account_id(account.account_id)

    expect(account).to be_truthy
  end
end

RSpec.describe AccountDAOInMemory do
  it_behaves_like 'AccountDAO Adapter'
end

RSpec.describe AccountDAOPostgres do
  it_behaves_like 'AccountDAO Adapter'
end
