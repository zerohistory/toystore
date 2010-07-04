module Toy
  class Attribute
    attr_reader :model, :name

    def initialize(model, name)
      @model = model
      @name  = name
    end
  end
end