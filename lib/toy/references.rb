module Toy
  module References
    extend ActiveSupport::Concern

    module ClassMethods
      def references
        @references ||= {}
      end

      def reference(name, *args)
        Reference.new(self, name, *args)
      end
    end
  end
end