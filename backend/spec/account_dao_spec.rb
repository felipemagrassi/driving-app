require 'account_dao_inmemory'
require 'account_dao_database'
require_relative '../lib/pg_promise_adapter'
require 'securerandom'

require 'account'

RSpec.shared_examples 'AccountDAO Adapter' do
  it 'should save an account and retrieve by email' do
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
    expect(account).to be_a(Account)
    expect(account.name).to eq(input[:name])
    expect(account.email).to eq(input[:email])
    expect(account.cpf).to eq(input[:cpf])
    expect(account.is_passenger).to be_truthy
    expect(account.is_driver).to be_falsey
    expect(account.car_plate).to eq(input[:car_plate])
  end

  it 'should save an account and retrieve by account_id' do
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
    expect(account).to be_a(Account)
    expect(account.name).to eq(input[:name])
    expect(account.email).to eq(input[:email])
    expect(account.cpf).to eq(input[:cpf])
    expect(account.is_passenger).to be_truthy
    expect(account.is_driver).to be_falsey
    expect(account.car_plate).to eq(input[:car_plate])
  end
end

RSpec.describe AccountDAOInMemory do
  let(:account_dao) { AccountDAOInMemory.new }

  include_examples 'AccountDAO Adapter', AccountDAOInMemory
end

RSpec.describe AccountDAODatabase do
  after { connection.close }

  context 'with postgres connection' do
    let(:connection) { PgPromiseAdapter.new }

    let(:account_dao) { AccountDAODatabase.new(connection:) }

    include_examples 'AccountDAO Adapter', AccountDAODatabase
  end
end
