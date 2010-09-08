module Toy
  class EmbeddedList
    include Toy::Collection

    def self.to_store(value, attribute)
      Array.to_store(value).map do |item|
        if item.respond_to?(:attributes)
          item.attributes
        else
          # Ensures that using foo_attributes correctly typecasts values
          attribute.embedded_list.type.new(item).attributes
        end
      end
    end

    def self.from_store(value, attribute)
      Array.from_store(value, attribute)
    end

    def key
      @key ||= :"#{name.to_s.singularize}_attributes"
    end

    class EmbeddedListProxy < Proxy
      def get(id)
        target.detect { |record| record.id == id }
      end

      def get!(id)
        get(id) || raise(Toy::NotFound.new(id))
      end

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
        proxy_class.new(attrs).tap do |instance|
          assign_reference(instance)
          if instance.valid?
            instance.instance_variable_set("@_new_record", false)
            push(instance)
            proxy_owner.save
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
            assign_reference(proxy_class.new(attrs))
          end
        end

        def assign_reference(instance)
          instance.parent_reference = proxy_owner
          instance
        end

        def target_attrs
          proxy_owner.send(proxy_key)
        end

        def target_attrs=(value)
          proxy_owner.send(:"#{proxy_key}=", value)
          reset
        end
    end

    private
      def define_attribute
        model.attribute(key, EmbeddedList, :embedded_list => self)
      end
      
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