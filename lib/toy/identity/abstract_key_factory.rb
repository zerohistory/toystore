module Toy
  module Identity
    class AbstractKeyFactory
      def next_key(object)
        raise NotImplementedError, "#{self.class.name}#next_key isn't implemented."
      end
    end
  end
end

