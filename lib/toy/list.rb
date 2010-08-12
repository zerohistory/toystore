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

    def instance_variable
      @instance_variable ||= :"@_#{name}"
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?

    private
      def create_accessors
        model.class_eval """
          def #{name}
            #{instance_variable} ||= #{type}.get_multi(#{key})
          end

          def #{name}=(instances)
            #{instance_variable} = nil
            self.#{key} = instances.map { |instance| instance.id }
          end
        """
      end
  end
end