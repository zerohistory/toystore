module Toy
  class Attribute
    attr_reader :model, :name, :type

    def initialize(model, name, type)
      @model, @name, @type = model, name.to_sym, type
      model.attributes[name] = self
    end

    def read(value)
      type.from_store(value)
    end

    def write(value)
      type.to_store(value)
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?
  end
end