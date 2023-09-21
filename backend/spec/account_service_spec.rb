require 'account_service'

RSpec.describe AccountService do
  xit 'should create an account' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              isPassanger: true }

    account_service = AccountService.new
    output = account_service.signup(input)
    account = account_service.account(output.account_id)

    expect(account).to_not be_nil
    expect(account.name).to eq(input[:name])
    expect(account.email).to eq(input[:email])
    expect(account.cpf).to eq(input[:cpf])
    expect(account.account_id).to be_truthy
  end

  it 'should not create an account with invalid name' do
    input = { name: 'John',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263728',
              isPassanger: true }

    account_service = AccountService.new
    expect { account_service.signup(input) }.to raise_error(ArgumentError)
  end

  it 'should not create an account with invalid email' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}",
              cpf: '96273263728',
              isPassanger: true }

    account_service = AccountService.new
    expect { account_service.signup(input) }.to raise_error(ArgumentError)
  end

  it 'should not create an account with invalid cpf' do
    input = { name: 'John Doe',
              email: "john.doe#{rand(1000)}@email.com",
              cpf: '96273263700',
              isPassanger: true }

    account_service = AccountService.new
    expect { account_service.signup(input) }.to raise_error(ArgumentError)
  end
end
