require_relative '../lib/signup'
require_relative '../lib/get_account'

require 'account_dao_inmemory'

RSpec.describe 'Account' do
  let(:account_dao) { AccountDAOInMemory.new }
  let(:signup) { Signup.new(account_dao:) }
  let(:get_account) { GetAccount.new(account_dao:) }

  it 'should create an passenger with stub' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_driver: false,
              verification_code: rand(1000).to_s,
              is_verified: false,
              is_passenger: true }

    account_dao_double = instance_double('AccountDAOPostgres')
    allow(account_dao_double).to receive(:save)
    allow(account_dao_double).to receive(:find_by_email)
    signup = Signup.new(account_dao: account_dao_double)
    output = signup.execute(input)
    input[:account_id] = output[:account_id]
    allow(account_dao_double).to receive(:find_by_account_id).and_return(input)
    get_account = GetAccount.new(account_dao: account_dao_double)
    account = get_account.execute(output[:account_id])

    expect(account).to be_truthy
    expect(account[:name]).to eq(input[:name])
    expect(account[:email]).to eq(input[:email])
    expect(account[:cpf]).to eq(input[:cpf])
    expect(account[:is_passenger]).to eq(input[:is_passenger])
    expect(account[:is_driver]).to eq(false)
    expect(account[:is_verified]).to eq(false)
    expect(account[:verification_code]).to be_truthy
    expect(account[:account_id]).to be_truthy
  end

  it 'should create an passenger with mock' do
    input = { name: 'John Doe', email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_driver: false,
              verification_code: rand(1000).to_s,
              is_verified: false,
              is_passenger: true }

    account_dao_double = instance_double('AccountDAO')
    signup = Signup.new(account_dao: account_dao_double)
    get_account = GetAccount.new(account_dao: account_dao_double)

    allow(account_dao_double).to receive(:save)
    allow(account_dao_double).to receive(:find_by_email)

    output = signup.execute(input)
    input[:account_id] = output[:account_id]
    allow(account_dao_double).to receive(:find_by_account_id).and_return(input)
    account = get_account.execute(output[:account_id])

    expect(account_dao_double).to have_received(:save).once
    expect(account_dao_double).to have_received(:find_by_email).with(input[:email]).once
    expect(account_dao_double).to have_received(:find_by_account_id).with(output[:account_id]).once
    expect(account).to be_truthy
    expect(account[:name]).to eq(input[:name])
    expect(account[:email]).to eq(input[:email])
    expect(account[:cpf]).to eq(input[:cpf])
    expect(account[:is_passenger]).to eq(input[:is_passenger])
    expect(account[:is_driver]).to eq(false)
    expect(account[:is_verified]).to eq(false)
    expect(account[:verification_code]).to be_truthy
    expect(account[:account_id]).to be_truthy
  end

  it 'should create an passenger with spy on mailer' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_driver: false,
              verification_code: rand(1000).to_s,
              is_verified: false,
              is_passenger: true }

    account_dao_double = instance_double('AccountDAO')
    mailer_gateway_double = instance_spy('MailerGateway')

    allow(account_dao_double).to receive(:save)
    allow(account_dao_double).to receive(:find_by_email)
    allow(mailer_gateway_double).to receive(:send)

    signup = Signup.new(account_dao: account_dao_double, mailer_gateway: mailer_gateway_double)
    output = signup.execute(input)
    input[:account_id] = output[:account_id]
    allow(account_dao_double).to receive(:find_by_account_id).and_return(input)
    get_account = GetAccount.new(account_dao: account_dao_double)
    account = get_account.execute(output[:account_id])

    expect(mailer_gateway_double).to have_received(:send).with(input[:email], 'Welcome to our app',
                                                               'You are now able to use our app')
    expect(account).to be_truthy
    expect(account[:name]).to eq(input[:name])
    expect(account[:email]).to eq(input[:email])
    expect(account[:cpf]).to eq(input[:cpf])
    expect(account[:is_passenger]).to eq(input[:is_passenger])
    expect(account[:is_driver]).to eq(false)
    expect(account[:is_verified]).to eq(false)
    expect(account[:verification_code]).to be_truthy
    expect(account[:account_id]).to be_truthy
  end

  it 'should create an passenger' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_driver: false,
              is_passenger: true }

    output = signup.execute(input)
    account = get_account.execute(output[:account_id])

    expect(account).to be_truthy
    expect(account.name).to eq(input[:name])
    expect(account.email).to eq(input[:email])
    expect(account.cpf).to eq(input[:cpf])
    expect(account.is_passenger).to eq(input[:is_passenger])
    expect(account.is_driver).to be_falsey
    expect(account.is_verified).to be_falsey
    expect(account.verification_code).to be_truthy
    expect(account.account_id).to be_truthy
  end

  it 'should not create an account with invalid name' do
    input = { name: 'John',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_passenger: true }

    expect { signup.execute(input) }.to raise_error(ArgumentError, 'Invalid Name')
  end

  it 'should not create an account with invalid email' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}",
              cpf: '96273263728',
              is_passenger: true }

    expect { signup.execute(input) }.to raise_error(ArgumentError, 'Invalid Email')
  end

  it 'should not create an account with invalid cpf' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263700',
              is_passenger: true }

    expect { signup.execute(input) }.to raise_error(ArgumentError, 'Invalid CPF')
  end

  it 'should not create an account when there is an already existing one' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_passenger: true }

    signup.execute(input)

    expect { signup.execute(input) }.to raise_error('Account already exists')
  end

  it 'should create an driver' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_driver: true,
              car_plate: 'AAA1234' }

    output = signup.execute(input)
    account = get_account.execute(output[:account_id])

    expect(account.account_id).to be_truthy
    expect(account.cpf).to eq(input[:cpf])
    expect(account.name).to eq(input[:name])
    expect(account.email).to eq(input[:email])
    expect(account.car_plate).to eq(input[:car_plate])
    expect(account.is_passenger).to eq(false)
    expect(account.is_driver).to eq(true)
  end

  it 'should not create an driver with invalid car plate' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              car_plate: 'ABC123',
              is_driver: true }

    expect { signup.execute(input) }.to raise_error(ArgumentError, 'Invalid car plate')
  end
end
