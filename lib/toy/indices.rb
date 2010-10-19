module Toy
  module Indices
    extend ActiveSupport::Concern

    module ClassMethods
      def indices
        @indices ||= {}
      end

      def index(name)
        Index.new(self, name)
      end

      def index_key(name, value)
        if index = indices[name.to_sym]
          index.key(value)
        else
          raise(ArgumentError, "Index for #{name} does not exist")
        end
      end

      def get_index(name, value)
        key = index_key(name, value)
        store.read(key) || []
      end

      def create_index(name, value, id)
        key = index_key(name, value)
        ids = get_index(name, value)
        ids.push(id) unless ids.include?(id)
        store.write(key, ids)
      end

      def destroy_index(name, value, id)
        key = index_key(name, value)
        ids = get_index(name, value)
        ids.delete(id)
        store.write(key, ids)
      end
    end

    module InstanceMethods
      def indices
        self.class.indices
      end

      def create_index(*args)
        self.class.create_index(*args)
      end

      def destroy_index(*args)
        self.class.destroy_index(*args)
      end
    end
  end
end