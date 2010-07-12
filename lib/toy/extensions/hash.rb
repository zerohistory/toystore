module Toy
  module Extensions
    module Hash
      def from_store(value)
        HashWithIndifferentAccess.new(value || {})
      end
    end
  end
end

class Hash
  extend Toy::Extensions::Hash
end