require 'account_service'

RSpec.describe AccountService do
  it 'should create an passenger' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_passenger: true }

    account_service = AccountService.new
    output = account_service.signup(input)
    account = account_service.account(output[:account_id])

    expect(account).to be_truthy
    expect(account[:name]).to eq(input[:name])
    expect(account[:email]).to eq(input[:email])
    expect(account[:cpf]).to eq(input[:cpf])
    expect(account[:is_passenger]).to eq(input[:is_passenger])
    expect(account[:is_driver]).to eq(false)
    expect(account[:account_id]).to be_truthy
  end

  it 'should not create an account with invalid name' do
    input = { name: 'John',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_passenger: true }

    account_service = AccountService.new
    expect { account_service.signup(input) }.to raise_error(ArgumentError, 'Invalid Name')
  end

  it 'should not create an account with invalid email' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}",
              cpf: '96273263728',
              is_passenger: true }

    account_service = AccountService.new
    expect { account_service.signup(input) }.to raise_error(ArgumentError, 'Invalid Email')
  end

  it 'should not create an account with invalid cpf' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263700',
              is_passenger: true }

    account_service = AccountService.new
    expect { account_service.signup(input) }.to raise_error(ArgumentError, 'Invalid CPF')
  end

  it 'should not create an account when there is an already existing one' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              is_passenger: true }

    account_service = AccountService.new
    account_service.signup(input)

    expect { account_service.signup(input) }.to raise_error('Account already exists')
  end

  it 'should create an driver' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              car_plate: 'AAA1234',
              is_driver: true }

    account_service = AccountService.new
    output = account_service.signup(input)

    account = account_service.account(output[:account_id])

    expect(account[:account_id]).to be_truthy
    expect(account[:cpf]).to eq(input[:cpf])
    expect(account[:is_driver]).to eq(true)
  end

  it 'should not create an driver with invalid car plate' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              car_plate: 'ABC123',
              is_driver: true }

    account_service = AccountService.new
    expect { account_service.signup(input) }.to raise_error(ArgumentError, 'Invalid car plate')
  end
end
