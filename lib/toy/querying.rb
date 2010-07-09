module Toy
  module Querying
    extend ActiveSupport::Concern

    module ClassMethods
      def [](id)
        load(store[store_key(id)])
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