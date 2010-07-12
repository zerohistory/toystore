module Toy
  class Attribute
    attr_reader :model, :name, :type

    def initialize(model, name, type)
      @model = model
      @name  = name
      @type  = type
    end
    
    def read(value)
      type.from_store(value)
    end
    
    def write(value)
      type.to_store(value)
    end
  end
end