require 'toy/proxies/proxy'

module Toy
  module Proxies
    class EmbeddedList < Toy::Proxies::Proxy
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
        self.target.push(instance)
      end
      alias :<< :push

      def concat(*instances)
        instances = instances.flatten
        instances.each do |instance|
          assert_type(instance)
          assign_reference(instance)
        end
        self.target.concat instances
      end

      def replace(instances)
        @target = instances.map do |instance|
          instance = instance.is_a?(proxy_class) ? instance : proxy_class.load(instance)
          assign_reference(instance)
        end
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
        target.delete_if { |instance| ids.include?(instance.id) }
        proxy_owner.save
      end

      private
        def find_target
          []
        end

        def assign_reference(instance)
          instance.parent_reference = proxy_owner
          instance
        end
    end
  end
end