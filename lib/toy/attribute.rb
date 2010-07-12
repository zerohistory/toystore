module Toy
  class Attribute
    attr_reader :model, :name, :type

    def initialize(model, name, type)
      @model = model
      @name  = name
      @type  = type
    end
  end
end