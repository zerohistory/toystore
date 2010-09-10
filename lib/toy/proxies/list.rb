require 'toy/proxies/proxy'

module Toy
  module Proxies
    class List < Toy::Proxies::Proxy
      def get(id)
        if target_ids.include?(id)
          proxy_class.get(id)
        end
      end

      def get!(id)
        get(id) || raise(Toy::NotFound.new(id))
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
        if proxy_options[:inverse_of]
          attrs.update(:"#{proxy_options[:inverse_of]}_id" => proxy_owner.id)
        end
        proxy_class.create(attrs).tap do |record|
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
        proxy_class.destroy(*ids)
        proxy_owner.reload
        self.target_ids = target_ids - ids
        proxy_owner.save
        reset
      end

      def reset
        @target = nil
      end

      private
        def find_target
          return [] if target_ids.blank?
          proxy_class.get_multi(target_ids)
        end

        def target_ids
          proxy_owner.send(proxy_key)
        end

        def target_ids=(value)
          ids = value.map do |item|
            if item.is_a?(proxy_class)
              item.id
            elsif item.is_a?(Hash)
              item['id']
            else
              item
            end
          end
          proxy_owner.send(:"#{proxy_key}=", ids)
          reset
        end
    end
  end
end