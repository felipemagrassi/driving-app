require 'pg'

class PgPromiseAdapter
  def initialize
    @connection = PG.connect('postgres://postgres:123456@localhost:5432/app')
  end

  def query(statement, data)
    connection.exec(statement, data)
  end

  def close
    connection&.close
  end

  private

  attr_reader :connection
end
