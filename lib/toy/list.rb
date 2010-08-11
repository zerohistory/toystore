module Toy
  class List
    attr_accessor :model, :name

    def initialize(model, name)
      @model, @name = model, name.to_sym
      model.lists[name] = self
      model.attribute(key, Array)
    end

    def type
      @type ||= name.to_s.classify.constantize
    end

    def key
      @key ||= :"#{name.to_s.singularize}_ids"
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?
  end
end