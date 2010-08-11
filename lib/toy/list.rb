module Toy
  class List
    attr_accessor :model, :name

    def initialize(model, name)
      @model, @name = model, name.to_sym
      model.lists[name] = self
      model.attribute(key, Array)
      create_accessors
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

    private
      def create_accessors
        model::ListAccessors.module_eval """
          def #{name}
            @#{name} ||= #{key}.map { |id| self.class[id] }
          end
        """
      end
  end
end