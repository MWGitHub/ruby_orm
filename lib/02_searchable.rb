require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    search = params.keys.join(' = ? AND ')
    search += ' = ?'

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{search}
    SQL
    results.map { |result| new(result) }
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
