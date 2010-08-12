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
        new(Toy.decode(json), true)
      end
    end
  end
end