module Toy
  class Attribute
    attr_reader :model, :name, :type, :options

    def initialize(model, name, type, options={})
      options.assert_valid_keys(:default, :embedded_list)
      @model, @name, @type, @options = model, name.to_sym, type, options
      model.attributes[name] = self
    end

    def read(value)
      type.from_store(value || default, self)
    end

    def write(value)
      type.to_store(value || default, self)
    end

    def default
      options[:default]
    end

    # Stores reference to related embedded list
    def embedded_list
      options[:embedded_list]
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?
  end
end