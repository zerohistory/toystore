module Toy
  module Extensions
    module Array
      def to_store(value, *)
        value = value.respond_to?(:lines) ? value.lines : value
        value.to_a
      end

      def from_store(value, *)
        value || []
      end
    end
  end
end

class Array
  extend Toy::Extensions::Array
end