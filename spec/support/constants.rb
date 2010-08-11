module Support
  module Constants
    def create_constant(constant)
      Object.send(:const_set, constant, Model(constant))
    end

    def remove_constant(constant)
      Object.send(:remove_const, constant)
    end

    def Model(name=nil, &block)
      klass = Class.new do
        include Toy::Store
        store RedisStore

        if name
          class_eval "def self.name; '#{name}' end"
          class_eval "def self.to_s; '#{name}' end"
        end
      end
      klass.class_eval(&block) if block_given?
      klass
    end
  end
end