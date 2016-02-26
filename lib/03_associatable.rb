require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name || class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name.singularize.downcase}_id".to_sym,
      class_name: name.camelcase,
      primary_key: :id
    }.merge(options)
    self.foreign_key = defaults[:foreign_key]
    self.class_name = defaults[:class_name]
    self.primary_key = defaults[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.singularize.downcase}_id".to_sym,
      class_name: name.singularize.camelcase,
      primary_key: :id
    }.merge(options)
    self.foreign_key = defaults[:foreign_key]
    self.class_name = defaults[:class_name]
    self.primary_key = defaults[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    belong_options = BelongsToOptions.new(name.to_s, options)
    assoc_options[name] = belong_options
    define_method(name) do
      model = belong_options.model_class
      belong_id = send(belong_options.foreign_key)
      model.find(belong_id)
    end
  end

  def has_many(name, options = {})
    many_options = HasManyOptions.new(name.to_s, self.name, options)
    define_method(name) do
      model = many_options.model_class
      primary = many_options.primary_key
      owner_id = send(many_options.primary_key)
      model.where(many_options.foreign_key => owner_id)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
