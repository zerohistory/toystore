module Toy
  module Extensions
    module Hash
      def store_default
        {}.with_indifferent_access
      end

      def from_store(value, *)
        value.nil? ? store_default : value.with_indifferent_access
      end
    end
  end
end

class Hash
  extend Toy::Extensions::Hash
end