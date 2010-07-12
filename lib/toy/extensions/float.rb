module Toy
  module Extensions
    module Float
      def to_store(value)
        value.nil? ? nil : value.to_f
      end
    end
  end
end

class Float
  extend Toy::Extensions::Float
end