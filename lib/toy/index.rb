module Toy
  class Index
    attr_accessor :model, :name

    def initialize(model, name)
      @model, @name = model, name.to_sym
      raise(ArgumentError, "No attribute #{name} for index") unless model.attribute?(name)

      model.indices[name] = self
      create_accessors
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?

    def store_key(value)
      [model.name, name, value].join(':')
    end

    private
      def create_accessors
        model.instance_eval """
          def find_by_#{name}(value)
            index = indices[:#{name}]
            index_key = index.store_key(value)
            id = store[index_key]
            id ? get(id) : nil
          end
        """

        model.class_eval """
          def add_to_#{name}_index
            index = self.class.indices[:#{name}]
            index_key = index.store_key(send(:#{name}))
            self.class.store[index_key] = self.id
          end

          after_save :add_to_#{name}_index

          def remove_from_#{name}_index
            index = self.class.indices[:#{name}]
            index_key = index.store_key(send(:#{name}))
            self.class.store.delete(index_key)
          end

          before_destroy :remove_from_#{name}_index
        """
      end

  end
end