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

    module ListProxy
      def push(instance)
        value = proxy_target_ids + [instance.id]
        proxy_owner.send("#{proxy_reflection.key}=", value)
      end
      alias :<< :push

      def concat(*instances)
        value = proxy_target_ids + instances.flatten.map { |i| i.id }
        proxy_owner.send("#{proxy_reflection.key}=", value)
      end

      def reset
        proxy_owner.instance_variable_set(proxy_reflection.instance_variable, nil)
      end

      def proxy_target_ids
        proxy_owner.send(proxy_reflection.key)
      end

      def create(attrs={})
        instance = proxy_reflection.type.create(attrs)
        if instance.persisted?
          push(instance)
          proxy_owner.save
          reset
        end
        instance
      end
    end

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
        model.proxy(name, :reflection => self, :extend => ListProxy)
      end
  end
end