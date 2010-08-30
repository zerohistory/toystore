module Toy
  class EmbeddedList
    include Toy::Collection

    def key
      @key ||= :"#{name.to_s.singularize}_attributes"
    end

    class EmbeddedListProxy < Proxy
      def include?(record)
        return false if record.nil?
        target.include?(record)
      end

      def push(instance)
        assert_type(instance)
        assign_reference(instance)
        self.target_attrs = target_attrs + [instance]
      end
      alias :<< :push

      def concat(*instances)
        instances = instances.flatten
        instances.map do |instance|
          assert_type(instance)
          assign_reference(instance)
        end
        self.target_attrs = target_attrs + instances
      end

      def replace(instances)
        self.target_attrs = instances
      end

      def create(attrs={})
        type.new(attrs).tap do |instance|
          if instance.valid?
            instance.initialize_from_database
            push(instance)
            proxy_owner.save
            reset
          end
        end
      end

      def destroy(*args, &block)
        ids = block_given? ? target.select(&block).map(&:id) : args.flatten
        target_attrs.delete_if { |attrs| ids.include?(attrs['id']) }
        proxy_owner.save
        reset
      end

      private
        def find_target
          target_attrs.map do |attrs|
            assign_reference(type.load(attrs))
          end
        end

        def assign_reference(instance)
          if instance.is_a?(Hash)
            instance.update(:parent_reference => proxy_owner)
          else
            instance.parent_reference = proxy_owner
          end
          instance
        end

        def target_attrs
          proxy_owner.send(key)
        end

        def target_attrs=(value)
          attrs = value.map do |item|
            item.respond_to?(:attributes) ? item.attributes : item
          end
          proxy_owner.send(:"#{key}=", attrs)
          reset
        end
    end

    private
      def create_accessors
        super
        type.class_eval { attr_accessor :parent_reference }
      end

      def proxy_class
        EmbeddedListProxy
      end

      def list_method
        :embedded_lists
      end
  end
end