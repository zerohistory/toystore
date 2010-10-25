module Toy
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def store(name=nil, client=nil)
        raise ArgumentError, 'Client is required' if !name.nil? && client.nil?

        if !name.nil? && !client.nil?
          @store = Adapter[name].new(client)
          stores << @store
        end

        @store
      end

      def stores
        @stores ||= []
      end

      def store_key(id)
        [self.name, id].join(':')
      end

      def create(attrs={})
        new(attrs).tap { |doc| doc.save }
      end

      def delete(*ids)
        ids.each { |id| get(id).try(:delete) }
      end

      def destroy(*ids)
        ids.each { |id| get(id).try(:destroy) }
      end
    end

    module InstanceMethods
      def store
        self.class.store
      end

      def stores
        self.class.stores
      end

      def store_key
        self.class.store_key(id)
      end

      def new_record?
        @_new_record == true
      end

      def destroyed?
        @_destroyed == true
      end

      def persisted?
        !new_record? && !destroyed?
      end

      def save(*)
        new_record? ? create : update
      end

      def update_attributes(attrs)
        self.attributes = attrs
        save
      end

      def destroy
        delete
      end

      def delete
        logger.debug("ToyStore DEL #{store_key.inspect}")
        @_destroyed = true
        store.delete(store_key)
      end

      private
        def create
          persist!
        end

        def update
          persist!
        end

        def persist
          @_new_record = false
        end

        def persist!
          key, attrs = store_key, persisted_attributes
          stores.reverse.each do |store|
            logger.debug("ToyStore SET :#{store.name} #{key.inspect}")
            logger.debug("  #{attrs.inspect}")
            store.write(key, attrs)
          end
          persist
          each_embedded_object(&:persist)
          true
        end
    end
  end
end