require_relative 'db_connection'
require 'active_support/inflector'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns.nil?
      result = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL
      @columns = result[0].map(&:to_sym)
    else
      @columns
    end
  end

  def self.finalize!
    @attributes = {}
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end
      define_method("#{column}=") do |v|
        attributes[column] = v
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || name.tableize
  end

  def self.all
    result = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        "#{table_name}"
    SQL
    parse_all(result)
  end

  def self.parse_all(results)
    results.map { |result| new(result) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    result.map { |result| new(result) }.first
  end

  def initialize(params = {})
    params.each do |k, v|
      sym = k.to_sym
      if self.class.columns.include?(sym)
        self.send("#{sym}=", v)
      else
        raise NoMethodError.new "unknown attribute '#{k}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    column_names = attributes.keys.join(', ')
    values = attribute_values
    questions = (['?'] * values.count).join(', ')
    DBConnection.execute(<<-SQL, *values)
      INSERT INTO
        #{self.class.table_name} (#{column_names})
      VALUES
        (#{questions})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    idx = attributes.keys.index(:id)

    keys = attributes.keys[0...idx] + attributes.keys[idx + 1..-1]
    column_names = keys.join(' = ?, ')
    column_names += ' = ?'

    values = attribute_values[0...idx] + attribute_values[idx + 1..-1]
    DBConnection.execute(<<-SQL, *values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{column_names}
      WHERE
        id = ?
    SQL
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end
end
