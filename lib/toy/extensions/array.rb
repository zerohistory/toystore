module Toy
  module Extensions
    module Array
      def store_default
        []
      end

      def to_store(value, *)
        value = value.respond_to?(:lines) ? value.lines : value
        value.to_a
      end

      def from_store(value, *)
        value || store_default
      end
    end
  end
end

class Array
  extend Toy::Extensions::Array
end