require_relative 'db_connection'

class Relation
  def initialize(table_name)
    @table_name = table_name
    @select_inputs = []
    @where_inputs = []
    @where_values = []
  end

  # Store each select input
  def select(inputs)
    # TODO: Allow symbol input as column
    inputs = inputs.split(',').map { |w| w.chomp.strip }
    inputs.each do |input|
      if inputs.length == 1
        @select_inputs << "#{table_name}." + input
      else
        @select_inputs << input
      end
    end
    self
  end

  def where(inputs, *values)
    @where_values += values
    @where_inputs << "(#{inputs})"
    self
  end

  def generate_query
    # Generate the SELECT
    if select_inputs.empty?
      query = "SELECT * "
    else
      query = "SELECT #{select_inputs.join(', ')} "
    end

    # Generate the FROM table
    query += "FROM #{table_name} "

    unless where_inputs.empty?
      query += "WHERE #{where_inputs.join(' AND ')} "
    end

    query
  end

  def query
    values = where_values
    result = DBConnection.execute(<<-SQL, *values)
      #{generate_query}
    SQL
    result
  end

  private
  attr_reader :table_name, :select_inputs, :where_inputs,
              :where_values
end
