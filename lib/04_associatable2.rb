require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      through_foreign = through_options.foreign_key
      through_key = through_options.primary_key
      through_table = through_options.table_name

      source_key = source_options.primary_key
      source_foreign = source_options.foreign_key
      source_table = source_options.table_name

      foreign_id = send(through_options.foreign_key)
      table_name = self.class.table_name

      results = DBConnection.execute(<<-SQL, foreign_id)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table} ON #{source_table}.#{source_key} =
            #{through_table}.#{source_foreign}
        WHERE
          #{through_table}.#{through_key} = ?
      SQL
      results.map { |result| source_options.model_class.new(result) }.first
    end
  end
end
