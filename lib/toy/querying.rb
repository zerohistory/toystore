module Toy
  module Querying
    extend ActiveSupport::Concern

    module ClassMethods
      def get(id)
        load(store[store_key(id)])
      end
      alias :[] :get

      def get_multi(*ids)
        ids.flatten.map { |id| get(id) }
      end

      def key?(id)
        store.key?(store_key(id))
      end
      alias :has_key? :key?

      def load(json)
        new(Toy.decode(json), true)
      end
    end
  end
end