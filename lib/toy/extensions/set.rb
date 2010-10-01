require 'set'

module Toy
  module Extensions
    module Set
      def store_default
        [].to_set
      end

      def to_store(value, *)
        value.to_a
      end

      def from_store(value, *)
        value.nil? ? store_default : value.to_set
      end
    end
  end
end

class Set
  extend Toy::Extensions::Set
end