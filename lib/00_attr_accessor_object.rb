class AttrAccessorObject
  def self.my_attr_accessor(*names)
    my_attr_reader(*names)
    my_attr_writer(*names)
  end

  def self.my_attr_reader(*names)
    names.each do |name|
      define_method(name) do
        instance_variable_get("@#{name}")
      end
    end
  end

  def self.my_attr_writer(*names)
    names.each do |name|
      define_method("#{name}=") do |v|
        instance_variable_set("@#{name}", v)
      end
    end
  end
end
