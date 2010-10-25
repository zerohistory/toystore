module Toy
  module Querying
    extend ActiveSupport::Concern

    module ClassMethods
      def get(id)
        key = store_key(id)
        value = nil
        populated_index = nil

        stores.each_with_index do |store, index|
          value = store.read(key)
          populated_index = index
          logger.debug("ToyStore GET :#{store.name} #{key.inspect}")
          logger.debug("  #{value.inspect}")
          break unless value.nil?
        end

        while populated_index > 0
          populated_index -= 1
          logger.debug("ToyStore RTS :#{stores[populated_index].name} #{key.inspect}")
          logger.debug("  #{value.inspect}")
          stores[populated_index].write(key, value)
        end

        load(value)
      end

      def get!(id)
        get(id) || raise(Toy::NotFound.new(id))
      end

      def get_multi(*ids)
        ids.flatten.map { |id| get(id) }
      end

      def get_or_new(id)
        get(id) || new(:id => id)
      end

      def get_or_create(id)
        get(id) || create(:id => id)
      end

      def key?(id)
        key = store_key(id)
        value = store.key?(key)
        logger.debug("ToyStore KEY #{key.inspect} #{value.inspect}")
        value
      end
      alias :has_key? :key?

      def load(attrs)
        return nil if attrs.nil?
        allocate.initialize_from_database(attrs)
      end
    end
  end
end