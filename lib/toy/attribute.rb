module Toy
  class Attribute
    attr_reader :model, :name, :type, :options

    def initialize(model, name, type, options={})
      options.assert_valid_keys(:default)
      @model, @name, @type, @options = model, name.to_sym, type, options
      model.attributes[name] = self
    end

    def read(value)
      type.from_store(value || default) 
    end

    def write(value)
      type.to_store(value || default)
    end

    def default
      options[:default]
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?
  end
end