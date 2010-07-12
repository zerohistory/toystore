module Toy
  module Extensions
    module String
      def to_store(value)
        value.nil? ? nil : value.to_s
      end

      def from_store(value)
        value.nil? ? nil : value.to_s
      end
    end
  end
end

class String
  extend Toy::Extensions::String
end