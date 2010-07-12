require 'set'

module Toy
  module Extensions
    module Set
      def to_store(value)
        value.to_a
      end

      def from_store(value)
        (value || []).to_set
      end
    end
  end
end

class Set
  extend Toy::Extensions::Set
end