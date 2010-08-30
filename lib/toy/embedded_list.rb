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

      def push(record)
        assert_type(record)
        self.target_attrs = target_attrs + [record.attributes]
      end
      alias :<< :push

      def concat(*records)
        records = records.flatten
        records.map { |record| assert_type(record) }
        self.target_attrs = target_attrs + records.map { |record| record.attributes }
      end

      def replace(records)
        reset
        self.target_attrs = records.map { |r| r.attributes }
      end

      def create(attrs={})
        record = type.new(attrs)
        if record.valid?
          record.initialize_from_database
          push(record)
          proxy_owner.save
          reset
        end
        record
      end

      def destroy(*args, &block)
        ids = block_given? ? target.select(&block).map(&:id) : args.flatten
        target_attrs.delete_if { |attrs| ids.include?(attrs['id']) }
        proxy_owner.save
        reset
      end

      private
        def find_target
          target_attrs.map { |attrs| type.load(attrs) }
        end

        def target_attrs
          proxy_owner.send(key)
        end

        def target_attrs=(value)
          proxy_owner.send(:"#{key}=", value)
        end
    end

    private
      def proxy_class
        EmbeddedListProxy
      end

      def list_method
        :embedded_lists
      end
  end
end