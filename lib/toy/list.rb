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

    def new_proxy(owner)
      ListProxy.new(self, owner)
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?

    class ListProxy
      include Enumerable
      extend  Forwardable

      def_delegators :@list, :model, :name, :type, :key

      def initialize(list, owner)
        @list, @owner = list, owner
      end

      def proxy_owner
        @owner
      end

      def target
        return [] if target_ids.blank?
        @target ||= type.get_multi(target_ids)
      end
      alias :to_a :target

      def each
        target.each { |i| yield(i) }
      end

      def eql?(other)
        target == other
      end
      alias :== :eql?

      def include?(instance)
        return false if instance.nil?
        target_ids.include?(instance.id)
      end

      def push(instance)
        self.target_ids = target_ids + [instance.id]
      end
      alias :<< :push

      def concat(*instances)
        self.target_ids = target_ids + instances.flatten.map { |i| i.id }
      end

      def reset
        @target = nil
      end

      def replace(instances)
        reset
        self.target_ids = instances.map { |i| i.id }
      end

      def create(attrs={})
        instance = type.create(attrs)
        if instance.persisted?
          push(instance)
          proxy_owner.save
          reset
        end
        instance
      end

      private
        def target_ids
          proxy_owner.send(key)
        end

        def target_ids=(value)
          proxy_owner.send("#{key}=", value)
        end

        def method_missing(method, *args, &block)
          target.send(method, *args, &block)
        end
    end

    private
      def create_accessors
        model.class_eval """
          def #{name}
            #{instance_variable} ||= self.class.lists[:#{name}].new_proxy(self)
          end

          def #{name}=(instances)
            #{name}.replace(instances)
          end
        """
      end
  end
end