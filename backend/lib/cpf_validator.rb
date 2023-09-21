# frozen_string_literal: true

class CpfValidator
  def validate(cpf)
    cpf = cpf.gsub(/\D/, '')
    return false if invalid_cpf?(cpf)

    first_digit = calculate_digit(cpf, 10)
    second_digit = calculate_digit(cpf, 11)

    first_digit.to_i == cpf[9].to_i && second_digit.to_i == cpf[10].to_i
  end

  private

  def invalid_cpf?(cpf)
    return true if cpf.empty?
    return true if cpf.size != 11
    return true if cpf.split('').uniq.size == 1

    false
  end

  def calculate_digit(cpf, factor)
    sum = 0

    factor.times do |i|
      sum += cpf[i].to_i * factor if factor > 1
      factor -= 1
    end

    rest = sum % 11

    rest < 2 ? 0 : 11 - rest
  end
end
