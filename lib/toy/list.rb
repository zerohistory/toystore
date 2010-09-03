module Toy
  class List
    include Toy::Collection

    def key
      @key ||= :"#{name.to_s.singularize}_ids"
    end

    class ListProxy < Proxy
      def get(id)
        if target_ids.include?(id)
          type.get(id)
        end
      end

      def include?(record)
        return false if record.nil?
        target_ids.include?(record.id)
      end

      def push(record)
        assert_type(record)
        self.target_ids = target_ids + [record]
      end
      alias :<< :push

      def concat(*records)
        records = records.flatten
        records.map { |record| assert_type(record) }
        self.target_ids = target_ids + records
      end

      def replace(records)
        reset
        self.target_ids = records
      end

      def create(attrs={})
        attrs.merge!(:"#{options[:inverse_of]}_id" => proxy_owner.id) if options[:inverse_of]
        type.create(attrs).tap do |record|
          if record.persisted?
            proxy_owner.reload
            push(record)
            proxy_owner.save
            reset
          end
        end
      end

      def destroy(*args, &block)
        ids = block_given? ? target.select(&block).map(&:id) : args.flatten
        type.destroy(*ids)
        proxy_owner.reload
        self.target_ids = target_ids - ids
        proxy_owner.save
        reset
      end

      private
        def find_target
          return [] if target_ids.blank?
          type.get_multi(target_ids)
        end

        def target_ids
          proxy_owner.send(key)
        end

        def target_ids=(value)
          ids = value.map do |item|
            if item.is_a?(type)
              item.id
            elsif item.is_a?(Hash)
              item['id']
            else
              item
            end
          end
          proxy_owner.send(:"#{key}=", ids)
        end
    end

    private
      def proxy_class
        ListProxy
      end

      def list_method
        :lists
      end

      def create_accessors
        super
        if options[:dependent]
          model.class_eval """
            after_destroy :destroy_#{name}
            def destroy_#{name}
              #{name}.each { |o| o.destroy }
            end
          """
        end
      end
  end
end