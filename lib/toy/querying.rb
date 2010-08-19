module Toy
  module Querying
    extend ActiveSupport::Concern

    module ClassMethods
      def get(id)
        load(store[store_key(id)])
      end
      alias :[] :get

      def get!(id)
        get(id) || raise(Toy::NotFound.new(id))
      end

      def get_multi(*ids)
        ids.flatten.map { |id| get(id) }
      end

      def key?(id)
        store.key?(store_key(id))
      end
      alias :has_key? :key?

      def load(json)
        return nil if json.nil?
        object = allocate
        object.initialize_from_database(Toy.decode(json))
      end
    end

    module InstanceMethods
      # Private, should only be called by .load
      def initialize_from_database(attrs={})
        @_new_record = false
        self.attributes = attrs
        self
      end

      def reload
        if attrs = store[store_key]
          self.attributes = Toy.decode(attrs)
        end
        self
      end
    end
  end
end