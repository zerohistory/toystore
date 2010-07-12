module Toy
  module Extensions
    module NilClass
      def to_store(value)
        value
      end

      def from_store(value)
        value
      end
    end
  end
end

class NilClass
  include Toy::Extensions::NilClass
end