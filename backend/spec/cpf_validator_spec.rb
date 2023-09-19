require 'cpf_validator'

RSpec.describe CpfValidator do
  ['95818705552',
   '01234567890',
   '565.486.780-60',
   '111.444.777.35'].each do |cpf|
    it "#{cpf} is valid" do
      cpf = CpfValidator.new(cpf)

      expect(cpf.validate).to be_truthy
    end
  end

  ['958.187.055-00',
   '958.187.055'].each do |cpf|
    it "#{cpf} is invalid" do
      cpf = CpfValidator.new(cpf)

      expect(cpf.validate).to be_falsey
    end
  end
end
