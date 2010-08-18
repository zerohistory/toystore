module Toy
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def store(new_store=nil)
        @store = new_store unless new_store.nil?
        @store
      end

      def store_key(id)
        [model_name.plural, id].join(':')
      end

      def create(attrs={})
        new(attrs).tap { |doc| doc.save }
      end

      def delete(*ids)
        ids.each do |id|
          next unless key?(id)
          self[id].delete
        end
      end

      def destroy(*ids)
        ids.each do |id|
          next unless key?(id)
          self[id].destroy
        end
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
        @_new_record
      end

      def destroyed?
        @_destroyed == true
      end

      def persisted?
        !new_record? && !destroyed?
      end

      def save
        create_or_update
      end
      
      def update_attributes(attrs)
        self.attributes = attrs
        save
      end

      def destroy
        delete
      end

      def delete
        @_destroyed = true
        store.delete(store_key)
      end

      private
        def create_or_update
          new_record? ? create : update
        end

        def create
          store[store_key] = Toy.encode(attributes)
          @_new_record = false
          true
        end

        def update
          store[store_key] = Toy.encode(attributes)
          true
        end
    end
  end
end