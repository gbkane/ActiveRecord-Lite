require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    col_names = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    col_names.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |col|

      define_method(col) do
        attributes[col]
      end

      define_method("#{col}=") do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    all = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    parse_all(all)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)

   obj = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?

    SQL

  parse_all(obj).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      send(col)
    end
  end

  def insert
    #self is Cat/Human object
    col_names = self.class.columns
    qs = []
    col_names.count.times do
      qs << "?"
    end
    qs = qs.join(', ')
    col_names = col_names.join(', ')
    p qs
    p col_names
    p self.attribute_values
    DBConnection.execute(<<-SQL, *self.attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{qs})
    SQL

    send("#{:id}=", DBConnection.last_insert_row_id)
  end

  def update
    col_names = self.class.columns.join(" = ?, ")
    col_names += " = ?"

    DBConnection.execute(<<-SQL, *self.attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = ?
    SQL
  end

  def save
    self.id.nil? ? self.insert : self.update

  end
end
