module Toy
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def store(new_store=nil, *args)
        @store = Toy.build_store(new_store, *args) unless new_store.nil?
        @store || Toy.store
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
          attrs = persisted_attributes
          logger.debug("ToyStore SET #{store_key.inspect} #{attrs.inspect}")
          store[store_key] = Toy.encode(attrs)
          persist
          each_embedded_object(&:persist)
          true
        end
    end
  end
end